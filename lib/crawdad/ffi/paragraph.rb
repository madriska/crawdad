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

    def calculate_demerits(r, new_item, active_breakpoint)
      C.calculate_demerits(@stream_ptr, active_breakpoint.position, 
        new_item, r, @flagged_penalty)
    end

    def adjustment_ratio(node_a, b)
      target_width = line_width(node_a.line + 1)

      C.adjustment_ratio(@total_width, @total_stretch, @total_shrink,
        node_a.total_width, node_a.total_stretch, node_a.total_shrink,
        target_width, @stream_ptr, b)
    end

    def calculate_widths(b)
      tw = FFI::MemoryPointer.new(:float).put_float32(0, @total_width)
      ty = FFI::MemoryPointer.new(:float).put_float32(0, @total_stretch)
      tz = FFI::MemoryPointer.new(:float).put_float32(0, @total_shrink)

      C.calculate_widths(@stream_ptr[b], tw, ty, tz)

      [tw.get_float32(0), ty.get_float32(0), tz.get_float32(0)]
    end

  end
  
end
