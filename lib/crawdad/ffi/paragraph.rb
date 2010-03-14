require 'fileutils'
require 'ffi'

module Crawdad

  class Paragraph

    module C
      extend FFI::Library
      ffi_lib "ext/crawdad.bundle"

      attach_function :calculate_demerits, 
        [:pointer, :int, :pointer, :float, :float], :float

      attach_function :adjustment_ratio,
        [:float, :float, :float, :float, :float, :float, :float, :pointer, 
          :int], :float

      attach_function :calculate_widths,
        [:pointer, :pointer, :pointer, :pointer], :void

      attach_function :inspect_token, [:pointer], :void

      attach_function :token_type, [:pointer], :int
      attach_function :is_box, [:pointer], :bool
      attach_function :is_glue, [:pointer], :bool
      attach_function :is_penalty, [:pointer], :bool
    end

    def initialize(stream, options={})
      @stream = stream

      # Set up C-accessible array of "token *"s
      @stream_ptr = FFI::MemoryPointer.new(:pointer, stream.length + 1)
      @stream_ptr.write_array_of_pointer(stream)

      @line_widths = options[:line_widths]
      @width = options[:width]
      @flagged_penalty = options[:flagged_penalty] || 3000
      @fitness_penalty = options[:fitness_penalty] || 100
    end

    def each_legal_breakpoint
      @total_width   = 0
      @total_stretch = 0
      @total_shrink  = 0

      @stream.each_with_index do |item, i|
        case C.token_type(item)
        when 0 # box
          @total_width += token_width(item)
        when 1 # glue
          # We can break here if we immediately follow a box.
          yield(item, i) if C.token_type(@stream[i-1]) == 0 # box
          @total_width   += token_width(item)
          @total_stretch += glue_stretch(item)
          @total_shrink  += glue_shrink(item)
        when 2 # penalty
          # We can break here unless inhibited by an infinite penalty.
          yield(item, i) unless penalty_penalty(item) == Infinity
        end
      end
    end

    def optimum_breakpoints(threshold=5)
      active_nodes = [Breakpoint.starting_node]
      each_legal_breakpoint do |item, bi|
        # "Main Loop" (Digital Typography p. 118)

        if active_nodes.empty?
          raise "No feasible solution. Try relaxing threshold."
        end

        ai = 0

        while active_nodes[ai]
          # For each fitness class, keep track of the nodes with the fewest
          # demerits so far.
          best = [nil] * 4

          while a = active_nodes[ai]
            j = a.line + 1 # current line
            lw = @width || @line_widths[j]

            r = C.adjustment_ratio(@total_width, @total_stretch, @total_shrink,
              a.total_width, a.total_stretch, a.total_shrink, lw, @stream_ptr,
              bi)

            if r < -1 || (C.is_penalty(item) &&
                          penalty_penalty(item) == -Infinity && 
                          a.position < @stream.length - 1)
              active_nodes.delete_at(ai)
            else
              ai += 1
            end

            if r >= -1 && r <= threshold
              d = C.calculate_demerits(@stream_ptr, a.position, item, r, 
                                       @flagged_penalty) + a.total_demerits
              c = self.class.fitness_class(r)

              # Penalize consecutive lines more than one fitness class away from
              # each other.
              if (c - a.fitness_class).abs > 1
                d += @fitness_penalty
              end

              # Update high scores if this is a new best.
              if best[c].nil? || d < best[c][:demerits]
                best[c] = {:node => a, :demerits => d, :ratio => r}
              end
            end

            # Add nodes to the active list before moving to the next line.
            if (next_node = active_nodes[ai]) && next_node.line >= j
              break
            end
          end

          # If we found any best nodes, add them to the active list.
          if ai && ai < active_nodes.length - 1
            active_nodes[ai, 0] = new_active_nodes(best, bi)
          else
            active_nodes.concat new_active_nodes(best, bi)
          end
        end

      end

      # At this point, everything in active_nodes should point to the final
      # element of our stream (the forced break). Now we pick the one with the
      # fewest total demerits.
      
      node = active_nodes.sort_by { |n| n.total_demerits }.first

      nodes = []
      begin
        nodes.unshift(node)
      end while node = node.previous

      nodes
    end

    def new_active_nodes(best, b, gamma=Infinity)
      lowest_demerits = best.compact.map { |n| n[:demerits] }.min

      tw = FFI::MemoryPointer.new(:float).put_float32(0, @total_width)
      ty = FFI::MemoryPointer.new(:float).put_float32(0, @total_stretch)
      tz = FFI::MemoryPointer.new(:float).put_float32(0, @total_shrink)
      C.calculate_widths(@stream_ptr[b], tw, ty, tz)
      new_width, new_stretch, new_shrink = 
        tw.get_float32(0), ty.get_float32(0), tz.get_float32(0)

      new_nodes = []

      # If we found any best nodes, add them to the active list.
      best.each_with_index do |n, fitness_class|
        next if n.nil?
        node, demerits, ratio = n[:node], n[:demerits], n[:ratio]
        next if demerits == Infinity || demerits > lowest_demerits + gamma 

        new_nodes << Breakpoint.new(b, node.line + 1, fitness_class, new_width,
                                    new_stretch, new_shrink, demerits, ratio, 
                                    node)
      end

      new_nodes
    end
    
  end
  
end
