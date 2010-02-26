# encoding: utf-8
# GangstaWrap: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

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
        stream << Box.new(w, "")
      end

      # Interword glue can stretch by half and shrink by a third.
      # TODO: optimal stretch/shrink ratios
      space_width = @pdf.width_of(" ")
      interword_glue = Glue.new(space_width, 
                                space_width / 2.0,
                                space_width / 3.0)

      # TODO: optimal values for sentence space w/y/z
      sentence_space_width = space_width * 2.0
      sentence_glue = Glue.new(sentence_space_width,
                               sentence_space_width / 2.0,
                               sentence_space_width / 3.0)

      # Break paragraph on whitespace.
      # TODO: how should "battle-\nfield" be tokenized?
      text.strip.split(/\s+/).each do |word|
        w = StringScanner.new(word)

        # For hyphenated words, follow each hyphen by a zero-width flagged
        # penalty.
        # TODO: recognize dashes in all their variants
        while seg = w.scan(/[^-]+-/) # "night-time" --> "<<night->>time"
          stream << Box.new(@pdf.width_of(seg), seg)
          stream << Penalty.new(50, 0, true)
        end

        stream << Box.new(@pdf.width_of(w.rest), w.rest)
        # TODO: add ties (~) or some other way to denote a period that
        # doesn't end a sentence.
        if w.rest =~ /\.$/
          stream << sentence_glue
        else
          stream << interword_glue
        end
      end

      # Remove extra glue at the end.
      stream.pop if Glue === stream.last

      # Finish paragraph with a penalty inhibiting a break, finishing glue (to
      # pad out the last line), and a forced break to finish the paragraph.
      stream << Penalty.new(Infinity)
      stream << Glue.new(0, Infinity, 0)
      stream << Penalty.new(-Infinity)

      stream
    end

  end

end

