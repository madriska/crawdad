require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "each_legal_breakpoint" do
  include GangstaWrap

  it "should yield at legal breakpoints" do
    stream = [
      b1=box(100),
      g2=glue(10, 5, 3),
      b3=box(100),
      p4=penalty(50),
      g5=glue(10, 5, 3),
      b6=box(100)
    ]

    para = Paragraph.new(stream)
    breaks = []
    para.each_legal_breakpoint { |item, *_| breaks << item }

    breaks.should == [g2, p4]
  end
end

