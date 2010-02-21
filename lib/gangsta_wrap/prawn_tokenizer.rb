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
    def paragraph(text, options={})
      stream = []

      if w = options[:indent]
        stream << Box.new(w)
      end

      # Interword glue can stretch by half and shrink by a third.
      space_width = @pdf.width_of(" ")
      interword_glue = Glue.new(space_width, 
                                space_width / 2.0,
                                space_width / 3.0)

      # Break paragraph on whitespace.
      text.split(/\s+/).each do |word|
        w = StringScanner.new(word)

        while seg = w.scan(/[^-]+-/)
          # Each hyphen is followed by a zero-width flagged penalty.
          stream << Box.new(@pdf.width_of(seg))
          stream << Penalty.new(50, 0, true)
        end

        stream << Box.new(@pdf.width_of(w.rest))
        stream << interword_glue
      end

      # Remove extra glue at the end.
      stream.pop if stream.last == interword_glue

      stream
    end

  end

end

