module GangstaWrap

  class Paragraph
    
    def initialize(stream)
      @stream = stream
    end

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

  end

end
