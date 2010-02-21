module GangstaWrap

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

end
