$:.unshift 'lib'
require 'gangsta_wrap'

$:.unshift '../prawn/lib'
require 'prawn/core'

Prawn::Document.generate("gettysburg.pdf") do |pdf|
  line_spacing = pdf.font.height

  stream, box_content = GangstaWrap::PrawnTokenizer.new(pdf).paragraph(<<-END)
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

  [200, 300, 400, 450].each do |width|
    para = GangstaWrap::Paragraph.new(stream, :width => width)
    words = box_content.each

    para.optimum_breakpoints.each_cons(2) do |a, b|
      # skip over glue and penalties at the beginning of each line
      first_box = a.position + 
        stream[a.position...b.position].index{|x| GangstaWrap::Box === x}

      x = 0
      stream[first_box...b.position].each do |token|
        case token
        when GangstaWrap::Box
          word = words.next
          pdf.draw_text!(word, :at => [x, pdf.cursor])
          x += token.width
        when GangstaWrap::Glue
          r = b.ratio
          w = case
               when r > 0
                 token.width + (r * token.stretch)
               when r < 0
                 token.width + (r * token.shrink)
               else token.width
               end
          x += w
        when GangstaWrap::Penalty
          # TODO: add a hyphen when we break at a flagged penalty
        end
      end
      pdf.draw_text("%6.03f" % b.ratio, :at => [width + 12, pdf.cursor])
      
      pdf.move_down(line_spacing)
    end

    pdf.move_down(line_spacing * 2)
  end

end
