# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")
include Crawdad::Tokens

describe "All items" do

  it "should have a width" do
    box     = box(12, '')
    glue    = glue(12, 1, 1)
    penalty = penalty(12, 12)

    token_width(box).should     == 12
    token_width(glue).should    == 12
    token_width(penalty).should == 12
  end

end

describe "Boxes" do

end

describe "Glue" do

  it "should have stretchability and shrinkability" do
    g = glue(12, 5, 6)
    token_width(g).should == 12
    glue_stretch(g).should == 5
    glue_shrink(g).should == 6
  end
  
end

describe "Penalties" do

  it "should accept penalty, width, and flagged arguments" do
    p = penalty(5, 10, true)
    penalty_penalty(p).should == 5
    token_width(p).should == 10
    assert penalty_flagged?(p)
  end

  it "should default its width to zero and flagged to false" do
    p = penalty(10)
    penalty_penalty(p).should == 10
    token_width(p).should.be.zero
    assert !penalty_flagged?(p)
  end

  it "should allow infinite penalties (positive or negative)" do
    forced = penalty(-Infinity)
    penalty_penalty(forced).should == -Infinity

    prohibited = penalty(Infinity)
    penalty_penalty(prohibited).should == Infinity
  end
  
end

