require 'fileutils'
require 'ffi'

module Crawdad

  class Paragraph

    module C
      extend FFI::Library
      ffi_lib ["ext/crawdad.bundle", "ext/crawdad.so"]

      attach_function :make_box, [:float, :string], :pointer
      attach_function :make_glue, [:float, :float, :float], :pointer
      attach_function :make_penalty, [:float, :float, :bool], :pointer

      attach_function :token_type, [:pointer], :int
      attach_function :is_box, [:pointer], :bool
      attach_function :is_glue, [:pointer], :bool
      attach_function :is_penalty, [:pointer], :bool

      attach_function :populate_active_nodes, [:pointer, :float, :float],
        BreakpointNode

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

    def optimum_breakpoints(threshold=5)
      node = BreakpointNode.new(
        C.populate_active_nodes(@stream_ptr, @width, threshold))

      nodes = []

      while node && !node.pointer.null?
        nodes.unshift(node)
        node = BreakpointNode.new(node[:previous])
      end

      nodes
    end

  end
  
end
