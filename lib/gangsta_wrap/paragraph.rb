module GangstaWrap

  class Paragraph
    
    def initialize(stream, options={})
      @stream = stream
      @line_lengths = options[:line_widths]
      @width = options[:width]
    end

    # An optional array of line widths indexed by line number. Can be used to
    # shape text as desired. Overrides +width+ if provided.
    #
    attr_accessor :line_widths

    # Width of the paragraph of text. Can be overridden on a per-line basis with
    # +line_widths+.
    #
    attr_accessor :width

    def optimum_breakpoints
      active = [Breakpoint.starting_node]
      each_legal_breakpoint do |item, i, tw, ty, tz|
        # TODO
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

  end

end
