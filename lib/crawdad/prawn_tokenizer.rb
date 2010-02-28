# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'strscan'
require 'enumerator'

module Crawdad

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
    # +options+:
    #
    # +hyphenation+::
    #   If provided, allow the given text to be hyphenated as needed to best
    #   fit the available space. Requires the text-hyphen gem. Allowable values:
    #   an ISO 639 language code (like 'pt'), or +true+ (synonym for 'en_us').
    # +indent+::
    #   If specified, indent the first line of the paragraph by the given
    #   number of PDF points.
    #
    def paragraph(text, options={})
      hyphenator = if options[:hyphenation]
        begin
          gem 'text-hyphen'
          require 'text/hyphen'
        rescue LoadError
          raise LoadError, ":hyphenation option requires the text-hyphen gem"
        end

        language = ((lang = options[:hyphenation]) == true) ? 'en_us' : lang
        @hyphenators ||= {}
        @hyphenators[language] ||= Text::Hyphen.new(:language => language)
      end

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
      sentence_space_width = space_width * 1.5
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
          stream.concat add_word_segment(seg, hyphenator)
        end

        stream.concat(add_word_segment(w.rest, hyphenator))

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

    protected

    # Returns a series of tokens representing the given word. Hyphenates using
    # the given +hyphenator+, if provided. Appends a zero-width flagged penalty
    # if the given word ends in a hyphen.
    #
    def add_word_segment(word, hyphenator)
      tokens = []

      if hyphenator
        hyphen_width = @pdf.width_of('-')

        splits = hyphenator.hyphenate(word)
        # For each hyphenated segment, add the box with an optional penalty.
        [0, *splits].each_cons(2) do |a, b|
          seg = word[a...b]
          tokens << Box.new(@pdf.width_of(seg), seg)
          tokens << Penalty.new(50, @pdf.width_of('-'), true)
        end

        last = word[(splits.last || 0)..-1]
        tokens << Box.new(@pdf.width_of(last), last)
      else
        tokens << Box.new(@pdf.width_of(word), word)
      end

      tokens << Penalty.new(50, 0, true) if word =~ /-$/
      tokens
    end

  end

end

