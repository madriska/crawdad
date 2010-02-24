require 'strscan'

module GangstaWrap

  # Ambassador to Prawn. Turns a paragraph into wrappable items.
  #
  class PrawnTokenizer

    # Sets up a tokenizer for the given document (+pdf+).
    #
    def initialize(pdf)
      @pdf = pdf
    end

    # Tokenize the given paragraph of text into a stream of items (boxes, glue,
    # and penalties).
    #
    # Returns [stream, box_content], where +box_content+ is an Array containing
    # the content for each Box that appears in +stream+, in turn.
    #
    def paragraph(text, options={})
      stream = []
      box_content = []
      $boxes_by_position = []

      if w = options[:indent]
        stream << Box.new(w)
        box_content << ""
        $boxes_by_position[stream.length - 1] = ""
      end

      # Interword glue can stretch by half and shrink by a third.
      space_width = @pdf.width_of(" ")
      interword_glue = Glue.new(space_width, 
                                space_width / 2.0,
                                space_width / 3.0)

      # Break paragraph on whitespace.
      # TODO: how should "battle-\nfield" be tokenized?
      text.split(/\s+/).each do |word|
        w = StringScanner.new(word)

        # For hyphenated words, follow each hyphen by a zero-width flagged
        # penalty.
        # TODO: recognize dashes in all their variants
        while seg = w.scan(/[^-]+-/) # "night-time" --> "<<night->>time"
          stream << Box.new(@pdf.width_of(seg))
          box_content << seg
          $boxes_by_position[stream.length - 1] = seg
          stream << Penalty.new(50, 0, true)
        end

        stream << Box.new(@pdf.width_of(w.rest))
        box_content << w.rest
        $boxes_by_position[stream.length - 1] = w.rest
        stream << interword_glue
      end

      # Remove extra glue at the end.
      stream.pop if stream.last == interword_glue

      # Finish paragraph with a penalty inhibiting a break, finishing glue (to
      # pad out the last line), and a forced break to finish the paragraph.
      stream << Penalty.new(Infinity)
      stream << Glue.new(0, Infinity, 0)
      stream << Penalty.new(-Infinity)

      [stream, box_content]
    end

  end

end

