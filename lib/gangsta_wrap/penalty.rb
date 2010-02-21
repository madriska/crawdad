module GangstaWrap

  # Represents a point at which the line of text can be broken.
  #
  class Penalty

    # Create a new Penalty with the given penalty (cost) value, a width to be
    # inserted upon breaking (for hyphenation), and +flagged+ set to true if
    # this is a "flagged" penalty.
    #
    def initialize(penalty, width=0, flagged=false)
      @penalty = penalty
      @width = width
      @flagged = flagged
    end
    
    # The penalty associated with breaking at this location. High values tend to
    # inhibit breaking here; negative values suggest a break. +Infinity and
    # -Infinity are also allowed.
    #
    attr_reader :penalty

    # Specifies the width to be inserted at this location if a break is chosen
    # (e.g., to insert a hyphen). The width is inserted just before the break.
    #
    attr_reader :width

    def flagged?
      @flagged
    end

  end

end
