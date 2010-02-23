module GangstaWrap

  class Paragraph
    
    def initialize(stream, options={})
      @stream = stream
      @line_lengths = options[:line_widths]
      @width = options[:width]
      @flagged_penalty = options[:flagged_penalty] || 3000
      @fitness_penalty = options[:fitness_penalty] || 100
    end

    # An optional array of line widths indexed by line number. Can be used to
    # shape text as desired. Overrides +width+ if provided.
    #
    attr_accessor :line_widths

    # Width of the paragraph of text. Can be overridden on a per-line basis with
    # +line_widths+.
    #
    attr_accessor :width

    def optimum_breakpoints(threshold=1)
      active_nodes = [Breakpoint.starting_node]
      each_legal_breakpoint do |item, bi|

        # For each fitness class, the best demerits we've seen so far, and the
        # active nodes that led us there.
        demerits = [Infinity] * 4
        best_nodes = [nil] * 4

        preva = nil

        if active_nodes.empty?
          raise "No feasible solution. Try relaxing threshold."
        end

        active_nodes.each_with_index do |a, ai|
          j = a.line + 1 # current line
          r = adjustment_ratio(a, bi)

          if r < -1 || (item.is_a?(Penalty) && item.penalty == -Infinity)
            active_nodes.delete(a)
          else
            preva = a
          end

          if r >= -1 && r <= threshold
            d = calculate_demerits(r, item, a) + a.total_demerits
            c = fitness_class(r)

            # Penalize consecutive lines more than one fitness class away from
            # each other.
            if (c - a.fitness_class).abs > 1
              d += @fitness_penalty
            end

            # Update high scores if this is a new best.
            if d < demerits[c]
              demerits[c] = d
              best_nodes[c] = a
            end
          end

          break if (next_node = active_nodes[ai+1]) && next_node.line >= j
        end
        
        # If we found any best nodes, add them to the active list.
        if demerits.min < Infinity
          # TODO
        end

      end
    end

    # For each item before which we could break, yields five values:
    #
    # +item+::
    #   The item we can break before (glue or penalty).
    # +i+::
    #   The index of +item+ in the stream.
    #
    def each_legal_breakpoint
      @total_width   = 0
      @total_stretch = 0
      @total_shrink  = 0

      @stream.each_with_index do |item, i|
        case item
        when Box
          @total_width += item.width
        when Glue
          # We can break here if we immediately follow a box.
          yield(item, i) if Box === @stream[i-1]
          @total_width   += item.width
          @total_stretch += item.stretch
          @total_shrink  += item.shrink
        when Penalty
          # We can break here unless inhibited by an infinite penalty.
          yield(item, i) unless item.penalty == Infinity
        else
          raise "Unknown item: #{item.inspect}"
        end
      end
    end

    # Calculates the adjustment ratio r by which a line from a to b would have
    # to be adjusted to fit in the given length. r==0 means the natural widths
    # are perfect. r==-1 means all of the shrinkability has been used; r==1
    # means all of the stretchability has been used.
    #
    # Arguments:
    # +node_a+:: 
    #   Breakpoint node of our starting point (on the active list).
    # +b+::
    #   Index (into +stream+) of the breakpoint under consideration.
    #
    def adjustment_ratio(node_a, b)
      item_b = @stream[b]
      # Find the width from a to b.
      width = @total_width - node_a.total_width
      # Add penalty width (hyphen) if we are breaking at a penalty
      width += item_b.width if Penalty === item_b
      target_width = line_width(node_a.line + 1)

      case
      when width < target_width
        stretch = @total_stretch - node_a.total_stretch
        (stretch > 0) ? (target_width - width) / stretch.to_f : Infinity
      when width > target_width
        shrink = @total_shrink - node_a.total_shrink
        (shrink > 0) ? (target_width - width) / shrink.to_f : Infinity
      else 0
      end
    end

    protected

    # Returns the width of the given line number +l+.
    #
    def line_width(l)
      (@line_widths && @line_widths[l]) || @width || 
        raise("You must specify either line_widths or width")
    end

    FlaggedPenaltyCharge = 100

    # Returns the demerits assessed to a break before +new_item+ with adjustment
    # ratio +r+, given the provided active breakpoint.
    #
    def calculate_demerits(r, new_item, active_breakpoint)
      d = case
          when new_item.is_a?(Penalty) && new_item.penalty >= 0
            (1 + 100*(r.abs ** 3) + new_item.penalty) ** 2
          when new_item.is_a?(Penalty) && new_item.penalty != -Infinity
            ((1 + 100*(r.abs ** 3)) ** 2) - (new_item.penalty ** 2)
          else
            (1 + 100*(r.abs ** 3)) ** 2
          end

      old_item = @stream[active_breakpoint.position]
      if old_item.is_a?(Penalty) && old_item.flagged? && 
         new_item.is_a?(Penalty) && new_item.flagged?
        d += @flagged_penalty
      end

      d
    end

    # Returns a fitness class number (0=tight, 1=normal, 2=loose, 3=very loose),
    # given the adjustment ratio +r+.
    #
    def fitness_class(r)
      case
      when r < -0.5 then 0
      when r <  0.5 then 1
      when r <  1   then 2
      else               3
      end
    end

  end

end
