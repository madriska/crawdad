# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")
include Crawdad::Tokens

describe "each_legal_breakpoint" do

  before(:each) do
    @stream = [
      @b0=box(100, ""),
      @g1=glue(10, 5, 3),
      @b2=box(100, ""),
      @p3=penalty(50),
      @g4=glue(10, 5, 3),
      @b5=box(100, "")
    ]

    @para = Paragraph.new(@stream)
  end

  it "should yield at legal breakpoints, with correct width/stretch/shrink" do
    breaks = []
    totals = []
    @para.each_legal_breakpoint do |item, i|
      breaks << item
      totals << [@para.instance_variable_get("@total_width"),
                 @para.instance_variable_get("@total_stretch"),
                 @para.instance_variable_get("@total_shrink")]
    end
    # These can be broken at the first glue or the first penalty. (Cannot break
    # at g4 because it is not preceded by a box.)
    breaks.should == [@g1, @p3]
    totals.should == [[100, 0, 0], # before g1
                      [210, 5, 3]] # before p3
  end
end

describe "adjustment_ratio" do

  before(:each) do
    @stream = [
      @b0=box(100, ""),
      @g1=glue(10, 5, 3),
      @b2=box(100, ""),
      @p3=penalty(50),
      @g4=glue(10, 5, 3),
      @b5=box(100, ""),
      @p6=penalty(-Infinity) # force break
    ]

    @para = Paragraph.new(@stream)

    # convenience: sums over entire stream
    @tw = @stream.inject(0){ |sum, i| sum + (token_type(i) == :penalty ? 0 : 
                                             token_width(i)) }
    @ty = @stream.select{|x| token_type(x) == :glue }.inject(0) { |sum, i| 
      sum + glue_stretch(i) }
    @tz = @stream.select{|x| token_type(x) == :glue }.inject(0) { |sum, i| 
      sum + glue_shrink(i) }
    @start = Breakpoint.starting_node
  end

  it "should be zero for a perfect fit (no adjustment needed)" do
    @para.width = @tw
    @para.optimum_breakpoints
    @para.adjustment_ratio(@start, 6).should.be.zero
  end

  it "should be positive when stretching, proportional to available stretch" do
    @para.width = @tw + (0.5 * @ty)
    @para.optimum_breakpoints
    @para.adjustment_ratio(@start, 6).should == 0.5
  end

  it "should be negative when shrinking, proportional to available shrink" do
    @para.width = @tw - (0.5 * @tz)
    @para.optimum_breakpoints
    @para.adjustment_ratio(@start, 6).should == -0.5
  end

end

