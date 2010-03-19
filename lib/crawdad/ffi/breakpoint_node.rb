require 'ffi'

module Crawdad
  extend FFI::Library

  class BreakpointNode < FFI::Struct
    layout :position,       :int,
           :line,           :int,
           :fitness_class,  :int,
           :total_width,    :float,
           :total_stretch,  :float,
           :total_shrink,   :float,
           :total_demerits, :float,
           :ratio,          :float,
           :previous,       :pointer,
           :link,           :pointer

    def position
      self[:position]
    end

    def position=(p)
      self[:position] = p
    end

    def ratio
      self[:ratio]
    end

    def inspect
      "#<BreakpointNode position=#{position} ratio=#{ratio}>"
    end
  end

end

