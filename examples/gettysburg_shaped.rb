# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

$:.unshift 'lib'
require 'crawdad'

$:.unshift 'vendor/prawn/lib'
require 'prawn'

Prawn::Document.generate("gettysburg_shaped.pdf") do |pdf|
  line_spacing = pdf.font.height

  stream = Crawdad::PrawnTokenizer.new(pdf).paragraph(<<-END)
  Fourscore and seven years ago our fathers brought forth
  on this continent a new nation, conceived in liberty, and
  dedicated to the proposition that all men are created equal.
  Now we are engaged in a great civil war, testing
  whether that nation, or any nation so conceived and so
  dedicated, can long endure. We are met on a great battle-field
  of that war. We have come to dedicate a portion of
  that field as a final resting-place for those who here gave
  their lives that that nation might live. It is altogether
  fitting and proper that we should do this.
  END

  para = Crawdad::Paragraph.new(stream, 
           :line_widths => (0..40).map{|x| 200 + 10*x})

  para.lines.each do |tokens, breakpoint|
    # skip over glue and penalties at the beginning of each line
    tokens.shift until Crawdad::Box === tokens.first

    x = 48
    tokens.each do |token|
      case token
      when Crawdad::Box
        pdf.draw_text!(token.content, :at => [x, pdf.cursor])
        x += token.width
      when Crawdad::Glue
        r = breakpoint.ratio
        w = case
             when r > 0
               token.width + (r * token.stretch)
             when r < 0
               token.width + (r * token.shrink)
             else token.width
             end
        x += w
      when Crawdad::Penalty
        # TODO: add a hyphen when we break at a flagged penalty
      end
    end
    pdf.draw_text("%6.03f" % breakpoint.ratio, :at => [0, pdf.cursor])
    
    pdf.move_down(line_spacing)
  end

  pdf.move_down(line_spacing * 2)

end
