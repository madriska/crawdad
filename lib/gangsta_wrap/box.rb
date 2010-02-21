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

end
