class NaiveDoc < Prawn::Document
  def paragraph(paragraph_text)
    text(paragraph_text, :align => :justify)
    move_down 6
  end
end

class RubyDoc < Prawn::Document
  def paragraph(paragraph_text)
    text(paragraph_text, :line_break_method => :KnuthPlass,
        :tokenizer_options => { :hyphenation => false })
    move_down 6
  end
end

$doc = lambda do
  # Open-source font courtesy of: http://www.theleagueofmoveabletype.com/
  font_families.update(
    "GoudyBookletter1911" => {
      :normal => "#{Prawn::BASEDIR}/data/fonts/GoudyBookletter1911.ttf"
    })
  font "GoudyBookletter1911"

  # Draws a section heading, centered in 80% of the current column's width.
  #
  def heading(heading_text)
    move_down 6 unless (y - bounds.absolute_top).abs < 1

    height = height_of(heading_text, :width => 0.8 * bounds.width)
    reflow_bounds = bounds.stretchy? ? margin_box : bounds
    bounds.move_past_bottom if (y - reflow_bounds.absolute_bottom) < height

    bounding_box([bounds.left_side - margin_box.left_side + 
                    (0.1 * bounds.width), cursor],
                  :width => 0.8 * bounds.width) do
      text heading_text, :align => :center
    end
    move_down 6
  end

  # Title page
  move_down 240
  text "The Prince", :size => 72, :align => :center
  text "Niccolo Machiavelli", :size => 36, :align => :center
  move_down 36
  text "translated by Ninian Hill Thomson", :size => 16, :align => :center

  start_new_page

  column_box([0, cursor], :columns => 2, :width => bounds.width) do
    mode = (RUBY_VERSION < "1.9") ? 'r' : 'r:UTF-8'
    File.open("#{Prawn::BASEDIR}/data/the_prince.txt", mode) do |f|

      until f.eof?
        case (line = f.gets.strip)
        when /^\s*$/         # no-op
        when /^= (.*)$/ then heading($1)
        else                 paragraph(line)
        end
      end

    end
  end

  repeat(:all, :dynamic => true) do
    if page_number > 1
      canvas do
        text_box "-#{page_number}-", :at => [0, 28], :align => :center
      end
    end
  end
end

