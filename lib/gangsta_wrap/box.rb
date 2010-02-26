# encoding: utf-8
# GangstaWrap: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module GangstaWrap

  # Represents a word or other atomic bit of content. For wrapping purposes,
  # boxes are opaque; GangstaWrap does not look into boxes to see what they
  # contain or modify them.
  #
  class Box

    def initialize(width, content)
      @width = width
      @content = content
    end

    # Width of the box.
    #
    attr_reader :width

    # "What's in the box?"
    #
    # This value is opaque to GangstaWrap, so user code can do anything it
    # wants with this; it can be a string, a formatted text object, an image,
    # really anything. It's just used to carry the content around with the box
    # instead of having to keep track of it separately.
    #
    attr_reader :content

  end

  def box(width, content)
    Box.new(width, content)
  end

end
