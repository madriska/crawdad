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

    def initialize(width)
      @width = width
    end

    # Width of the box.
    #
    attr_reader :width

  end

  def box(width)
    Box.new(width)
  end

end
