require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn tokenizer" do
  include GangstaWrap

  before(:each) do
    @pdf = Prawn::Document.new
    @tokenizer = PrawnTokenizer.new(@pdf)
  end

  # These specs are inspired by Digital Typography, pp. 72-73

  # (1)
  it "should prepend an empty box for paragraph indentation" do
    unindented = @tokenizer.paragraph("foo")
    indented = @tokenizer.paragraph("foo", :indent => 12)

    # Ensure there is an extra box for the indentation.
    indented.grep(Box).length.should == unindented.grep(Box).length + 1

    # Indentation box should be the width requested.
    indented.first.should.be.a.kind_of(Box)
    indented.first.width.should == 12
  end

  # (2)
  it "should create boxes for each word, including punctuation" do
    stream = @tokenizer.paragraph("this is a test.")
    boxes = stream.grep(Box)

    boxes.length.should == 4
    boxes.zip(%w[this is a test.]).each do |box, word|
      box.width.should == @pdf.width_of(word)
    end
  end

  # TODO: insert flagged penalties at hyphenation points
  
  # (3)
  it "should insert glue between words" do
    stream = @tokenizer.paragraph("this is a test.")
    stream.map{ |i| i.class }.should == [Box, Glue, Box, Glue, Box, Glue, Box]

    interword_width = @pdf.width_of(" ")
    stream.grep(Glue).each do |glue|
      glue.width.should == interword_width
    end
  end

  # (4)
  it "should follow explicit hyphens with zero-width flagged penalties" do
    stream = @tokenizer.paragraph("night-time")
    stream.map{ |i| i.class }.should == [Box, Penalty, Box]
    stream.first.width.should == @pdf.width_of("night-")

    penalty = stream[1]
    penalty.width.should.be.zero
    penalty.should.be.flagged
  end

end
