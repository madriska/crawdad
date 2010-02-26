# encoding: utf-8
# GangstaWrap: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "All items" do
  include GangstaWrap

  it "should have a width" do
    box     = Box.new(12, '')
    glue    = Glue.new(12, 1, 1)
    penalty = Penalty.new(12, 12)

    box.width.should     == 12
    glue.width.should    == 12
    penalty.width.should == 12
  end

end

describe "Boxes" do

end

describe "Glue" do
  include GangstaWrap

  it "should have stretchability and shrinkability" do
    g = Glue.new(12, 5, 6)
    g.width.should == 12
    g.stretch.should == 5
    g.shrink.should == 6
  end
  
end

describe "Penalties" do
  include GangstaWrap

  it "should accept penalty, width, and flagged arguments" do
    p = Penalty.new(5, 10, true)
    p.penalty.should == 5
    p.width.should == 10
    p.should.be.flagged
  end

  it "should default its width to zero and flagged to false" do
    p = Penalty.new(10)
    p.penalty.should == 10
    p.width.should.be.zero
    p.should.not.be.flagged
  end

  it "should allow infinite penalties (positive or negative)" do
    favored = Penalty.new(-Infinity)
    favored.penalty.should == -Infinity

    disfavored = Penalty.new(Infinity)
    disfavored.penalty.should == Infinity
  end
  
end

