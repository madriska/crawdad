# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Crawdad

  # A node in the breakpoint list.
  #
  class Breakpoint
    
    # Returns the node used for the head of the active list -- represents the
    # starting point.
    #
    def self.starting_node
      new(position=0, line=0, fitness_class=1, total_width=0, total_stretch=0, 
          total_shrink=0, total_demerits=0, ratio=0.0, previous=nil)
    end

    # Creates a breakpoint node with the given parameters.
    #
    def initialize(position, line, fitness_class, total_width, total_stretch,
                   total_shrink, total_demerits, ratio, previous)
      @position       = position
      @line           = line
      @fitness_class  = fitness_class
      @total_width    = total_width
      @total_stretch  = total_stretch
      @total_shrink   = total_shrink
      @total_demerits = total_demerits
      @ratio          = ratio
      @previous       = previous
    end

    # Index of this breakpoint within the sequence of items.
    #
    attr_accessor :position

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

    # The ratio of stretch or shrink used for the line ending at this
    # breakpoint. 0 is a perfect fit; +1 means 100% of the stretch has been
    # used; -1 means all of the shrink has been used.
    #
    attr_reader :ratio

    # Link to the best preceding breakpoint.
    #
    attr_reader :previous

    def inspect
      "#<Breakpoint position=#{@position} ratio=#{@ratio}>"
    end

  end

end
