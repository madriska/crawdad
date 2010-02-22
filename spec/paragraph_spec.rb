require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "each_legal_breakpoint" do
  include GangstaWrap

  before(:each) do
    @stream = [
      @b1=box(100),
      @g2=glue(10, 5, 3),
      @b3=box(100),
      @p4=penalty(50),
      @g5=glue(10, 5, 3),
      @b6=box(100)
    ]

    @para = Paragraph.new(@stream)
  end

  it "should yield at legal breakpoints, with correct width/stretch/shrink" do
    breaks = []
    totals = []
    @para.each_legal_breakpoint do |item, i, tw, ty, tz| 
      breaks << item
      totals << [tw, ty, tz]
    end
    # These can be broken at the first glue or the first penalty. (Cannot break
    # at g5 because it is not preceded by a box.)
    breaks.should == [@g2, @p4]
    totals.should == [[100, 0, 0], # before g2
                      [210, 5, 3]] # before p4
  end
end

