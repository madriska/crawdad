module GangstaWrap

  # A node in the breakpoint list.
  #
  class Breakpoint
    
    # Returns the node used for the head of the active list -- represents the
    # starting point.
    #
    def self.starting_node
      new(position=0, line=0, fitness_class=1, total_width=0, total_stretch=0, 
          total_shrink=0, total_demerits=0, previous=nil, link=nil)
    end

    # Creates a breakpoint node with the given parameters.
    #
    def initialize(position, line, fitness_class, total_width, total_stretch,
                   total_shrink, total_demerits, previous, link)
      @position       = position
      @line           = line
      @fitness_class  = fitness_class
      @total_width    = total_width
      @total_stretch  = total_stretch
      @total_shrink   = total_shrink
      @total_demerits = total_demerits
      @previous       = previous
      @link           = link
    end

    # Index of this breakpoint within the sequence of items.
    #
    attr_reader :position

    # Number of the line ending at this breakpoint.
    #
    attr_reader :line

    # Fitness class (0=tight, 1=normal, 2=loose, 3=very loose) of the line
    # ending at this breakpoint.
    #
    attr_reader :fitness_class

    # Total width up to after(self). Used to calculate adjustment ratios.
    #
    attr_reader :total_width

    # Total stretch up to after(self). Used to calculate adjustment ratios.
    #
    attr_reader :total_stretch

    # Total shrink up to after(self). Used to calculate adjustment ratios.
    #
    attr_reader :total_shrink

    # Minimum total demerits up to this breakpoint.
    #
    attr_reader :total_demerits

    # Link to the best preceding breakpoint.
    #
    attr_reader :previous

    # Link to the next node in the list.
    #
    attr_reader :link


  end

end
