# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn tokenizer" do

  before(:each) do
    @pdf = CachedWidthDocument
    @tokenizer = PrawnTokenizer.new(@pdf)
  end

  # These specs are inspired by Digital Typography, pp. 72-73

  # (1)
  it "should prepend an empty box for paragraph indentation" do
    unindented_stream = @tokenizer.paragraph("foo")
    indented_stream   = @tokenizer.paragraph("foo", :indent => 12)

    # Ensure there is an extra box for the indentation.
    indented_stream.select{|x| token_type(x) == :box}.length.should == 
      unindented_stream.select{|x| token_type(x) == :box}.length + 1

    # Indentation box should be the width requested.
    token_type(indented_stream.first).should == :box
    token_width(indented_stream.first).should == 12

    # Box content should have one entry for each of the boxes.
    box_content(unindented_stream[0]).should == "foo"
    box_content(indented_stream[0]).should == ""
    box_content(indented_stream[1]).should == "foo"
  end

  # (2)
  it "should create boxes for each word, including punctuation" do
    stream = @tokenizer.paragraph("this is a test.")
    boxes = stream.select{|x| token_type(x) == :box}

    boxes.length.should == 4
    boxes.zip(%w[this is a test.]).each do |box, word|
      token_width(box).should == @pdf.width_of(word)
    end

    boxes.map { |b| box_content(b) }.should == %w[this is a test.]
  end

  # (3)
  it "should insert glue between words" do
    stream = @tokenizer.paragraph("this is a test.")
    3.times{ stream.pop } # remove finishing elements
    stream.map{ |t| token_type(t) }.should == 
      [:box, :glue, :box, :glue, :box, :glue, :box]

    interword_width = @pdf.width_of(" ")
    stream.select{|t| token_type(t) == :glue}.each do |glue|
      token_width(glue).should == interword_width
    end
  end

  # (4)
  it "should follow explicit hyphens with zero-width flagged penalties" do
    stream = @tokenizer.paragraph("cul-de-sac")
    3.times{ stream.pop } # remove finishing elements
    stream.map{ |t| token_type(t) }.should == 
      [:box, :penalty, :box, :penalty, :box]

    # check boxes
    token_width(stream[0]).should == @pdf.width_of("cul-")
    token_width(stream[2]).should == @pdf.width_of("de-")
    token_width(stream[4]).should == @pdf.width_of("sac")

    stream.select{|b| token_type(b) == :box}.map { |b| 
        box_content(b) }.should == 
      %w[cul- de- sac]

    # check penalties
    token_width(stream[1]).should.be.zero
    assert penalty_flagged?(stream[1])
    token_width(stream[3]).should.be.zero
    assert penalty_flagged?(stream[3])
  end

  # (5)
  it "should finish paragraphs with a disallowed break, finishing glue, and" +
     "forced break" do
    stream = @tokenizer.paragraph("foo bar baz")
    forced_break = stream.pop
    finishing_glue = stream.pop
    disallowed_break = stream.pop
    
    token_type(disallowed_break).should == :penalty
    penalty_penalty(disallowed_break).should == Infinity

    token_type(finishing_glue).should == :glue
    token_width(finishing_glue).should.be.zero
    glue_stretch(finishing_glue).should == Infinity

    token_type(forced_break).should == :penalty
    penalty_penalty(forced_break).should == -Infinity
    # check this, because we will break here for sure
    token_width(forced_break).should.be.zero
  end

  it "should insert extra space after sentence-ending periods" do
    stream = @tokenizer.paragraph("bork bork bork. bork bork bork")
    normal_glue = stream.detect { |t| token_type(t) == :glue }

    i = stream.find_index { |t| token_type(t) == :box && 
      box_content(t) == 'bork.' }
    sentence_glue = stream[i+1]

    token_type(sentence_glue).should == :glue
    token_width(sentence_glue).should.be > token_width(normal_glue)
  end

  describe "with hyphenation" do
    
    it "should insert flagged penalties at each hyphenation point" do
      stream = @tokenizer.paragraph("testing", :hyphenation => true)
      3.times { stream.pop }

      stream.map { |t| token_type(t) }.should == [:box, :penalty, :box]

      box_content(stream[0]).should == "test"
      token_width(stream[1]).should == @pdf.width_of('-')
      assert penalty_flagged?(stream[1])
      box_content(stream[2]).should == "ing"
    end

    it "should not affect manually hyphenated words" do
      stream = @tokenizer.paragraph("play-thing", :hyphenation => true)
      3.times { stream.pop }

      stream.map { |t| token_type(t) }.should == [:box, :penalty, :box]
      box_content(stream[0]).should == 'play-'
      token_width(stream[1]).should.be.zero
      assert penalty_flagged?(stream[1])
      box_content(stream[2]).should == "thing"
    end

  end

end
