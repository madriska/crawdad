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

para = GangstaWrap::Paragraph.new(stream, :width => 200)

para.optimum_breakpoints.each_cons(2) do |a, b|
  puts $boxes_by_position[a.position...b.position].compact.join(" ")
end
