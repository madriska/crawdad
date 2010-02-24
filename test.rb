$:.unshift 'lib'
require 'gangsta_wrap'

$:.unshift '../prawn/lib'
require 'prawn/core'

pdf = Prawn::Document.new
stream, box_content = GangstaWrap::PrawnTokenizer.new(pdf).paragraph(<<END)
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

Width = 200
para = GangstaWrap::Paragraph.new(stream, :width => Width)

Prawn::Document.generate("test.pdf") do |pdf|
  line_spacing = pdf.font.height # TODO: + leading if any. Maybe incorporate
                                 # into Text::Box?
  y = pdf.cursor

  para.optimum_breakpoints.each_cons(2) do |a, b|
    # for each line
    x = 0
    first_box = a.position + stream[a.position...b.position].index{|x| GangstaWrap::Box === x}
    stream[first_box...b.position].each do |token|
      case token
      when GangstaWrap::Box
        word = box_content.shift
        pdf.draw_text!(word, :at => [x, y])
        print "%s %.02f " % [word, token.width]
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
        print "(%.02f) " % w
        x += w
      else # no-op
      end
    end
    print " ==> %.02f" % x
    pdf.text_box("%.03f" % b.ratio, :at => [Width + 12, y+9], :align => :right,
                  :width => 36)
    puts
    
    y -= line_spacing
  end
end
