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
      each_legal_breakpoint do |item, bi, tw, ty, tz|

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
          r = adjustment_ratio(a, bi, tw, ty, tz)

          if r < -1 || (item.is_a?(Penalty) && item.penalty = -Infinity)
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
    # +total_width+::
    #   Total width of the text up to, but not including, this item.
    # +total_stretch+::
    #   Total stretchability of glue items up to, but not including, this item.
    # +total_shrink+::
    #   Total shrinkability of glue items up to, but not including, this item.
    #
    def each_legal_breakpoint # :yields: item, i, total_width, total_stretch, 
                              #          total_shrink
      tw = ty = tz = 0 # total width, stretch, shrink
      @stream.each_with_index do |item, i|
        case item
        when Box
          tw += item.width
        when Glue
          # We can break here if we immediately follow a box.
          yield(item, i, tw, ty, tz) if Box === @stream[i-1]
          tw += item.width
          ty += item.stretch
          tz += item.shrink
        when Penalty
          # We can break here unless inhibited by an infinite penalty.
          yield(item, i, tw, ty, tz) unless item.penalty == Infinity
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
    # +tw+::
    #   Current value of total width at +b+. Passed into this method to avoid
    #   recalculating widths for each call to this method.
    # +ty+::
    #   Current value of total stretch at +b+.
    # +tz+::
    #   Current value of total shrink at +b+.
    #
    def adjustment_ratio(node_a, b, tw, ty, tz)
      item_b = @stream[b]
      # Find the width from a to b.
      width = tw - node_a.total_width
      # Add penalty width (hyphen) if we are breaking at a penalty
      width += item_b.width if Penalty === item_b
      target_width = line_width(node_a.line + 1)

      case
      when width < target_width
        stretch = ty - node_a.total_stretch
        (stretch > 0) ? (target_width - width) / stretch.to_f : Infinity
      when width > target_width
        shrink = tz - node_a.total_shrink
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
