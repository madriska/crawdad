require 'ffi'

module Crawdad
  module Tokens
    extend FFI::Library

    Type = enum(:box, :glue, :penalty)

    def token_type(token)
      token[:type]
    end

    class Box < FFI::Struct
      attr_accessor :content
      layout :type,    Type,
             :width,   :double
    end

    def box(width, content)
      b = Box.new
      b[:type]  = :box
      b[:width] = width
      b.content = content
      b
    end

    def box_content(b)
      b.content
    end

    class Glue < FFI::Struct
      layout :type,    Type,
             :width,   :double,
             :stretch, :double,
             :shrink,  :double
    end

    def glue(width, stretch, shrink)
      g = Glue.new
      g[:type]    = :glue
      g[:width]   = width
      g[:stretch] = stretch
      g[:shrink]  = shrink
      g
    end

    def glue_stretch(glue)
      glue[:stretch]
    end

    def glue_shrink(glue)
      glue[:shrink]
    end

    class Penalty < FFI::Struct
      layout :type,    Type,
             :width,   :double,
             :penalty, :double,
             :flagged, :int
    end
    
    def penalty(penalty, width=0.0, flagged=false)
      p = Penalty.new
      p[:type]    = :penalty
      p[:width]   = width
      p[:penalty] = penalty
      p[:flagged] = flagged ? 1 : 0
      p
    end

    def penalty_penalty(p)
      p[:penalty]
    end

    def penalty_flagged?(p)
      p[:flagged] != 0
    end

    def token_width(token)
      token[:width]
    end

  end
end
