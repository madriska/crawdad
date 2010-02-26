# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Crawdad

  # Glue is a variable-width amount of white space between words on a line. It
  # is specified by a given ideal width, plus stretchability and shrinkability
  # (in the same units).
  #
  class Glue

    # Creates a bit of glue, given an ideal width, plus stretchability and
    # shrinkability in the same units.
    #
    def initialize(width, stretch, shrink)
      @width = width
      @stretch = stretch
      @shrink = shrink
    end

    # Ideal width of the glue.
    #
    attr_reader :width

    # Amount by which the glue can stretch to fill needed space.
    #
    attr_reader :stretch

    # Amount by which the glue can shrink.
    #
    attr_reader :shrink

  end

  def glue(width, stretch, shrink)
    Glue.new(width, stretch, shrink)
  end

end
