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

    include Tokens

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
      @align = options[:align] || :justify

      hyphenator = if options[:hyphenation]
        # Box-glue-penalty model does not easily permit optional hyphenation
        # with the construction we use for centered text.
        if @align == :center
          raise ArgumentError, "Hyphenation is not supported with centered text"
        end

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

      stream = starting_tokens(options[:indent])

      # Break paragraph on whitespace.
      # TODO: how should "battle-\nfield" be tokenized?
      words = text.strip.split(/\s+/)
      
      words.each_with_index do |word, i|
        w = StringScanner.new(word)

        # For hyphenated words, follow each hyphen by a zero-width flagged
        # penalty.
        while seg = w.scan(/[^-]+-/) # "night-time" --> "<<night->>time"
          stream += word_segment(seg, hyphenator)
        end

        stream += word_segment(w.rest, hyphenator)
        
        unless i == words.length - 1
          stream += interword_tokens
        end
      end

      # Add needed tokens to finish off the paragraph.
      stream += finishing_tokens

      stream
    end

    protected

    # Width of one space.
    #
    def space
      @space ||= @pdf.width_of(" ")
    end

    # Tokens used to start a paragraph. Accepts one argument, +indent_width+,
    # the amount by which to indent the first line, which only really makes
    # sense for justified or ragged-left text.
    #
    def starting_tokens(indent_width)
      if @align == :center
        [box(0, ""), glue(0, 3*space, 0)]
      elsif indent_width
        [box(w, "")]
      else
        []
      end
    end

    # Tokens used between words in a sentence. This depends on @align; the
    # box-glue-penalty model is flexible enough to accommodate ragged (right or
    # left), centered, or justified text.
    #
    # See Digital Typography pp. 93-95 for details.
    #
    def interword_tokens
      case @align
      when :justify
        [glue(space, space / 2.0, space / 3.0)]
      when :center
        [glue(0, 3*space, 0), penalty(0), glue(space, -6*space, 0), box(0, ""),
          penalty(Infinity), glue(0, 3*space, 0)]
      else # :right, :left
        [glue(0, 3*space, 0), penalty(0), glue(space, -3*space, 0)]
      end
    end

    # Tokens representing a possible hyphenation point.
    #
    def optional_hyphen
      hyphen = @pdf.width_of('-')

      if @align == :justify
        [penalty(50, hyphen, true)]
      else # :left or :right (:center is incompatible with hyphenation)
        # Hyphens cost 10 times more in unjustified text because we can usually
        # do better to avoid them.
        [penalty(Infinity), glue(0, 3*space, 0), penalty(500, hyphen, true), 
          glue(0, -3*space, 0)]
      end
    end

    # Tokens to finish out a paragraph -- pad out the last line if needed, and
    # force a break.
    #
    def finishing_tokens
      if @align == :center
        [glue(0, 3*space, 0), penalty(-Infinity)]
      else
        [penalty(Infinity), glue(0, Infinity, 0), penalty(-Infinity)]
      end
    end

    # Returns tokens representing the given word. Hyphenates using the given
    # +hyphenator+, if provided. Appends a zero-width flagged penalty if the
    # given word ends in a hyphen.
    #
    def word_segment(word, hyphenator)
      tokens = []

      if hyphenator
        begin
          splits = hyphenator.hyphenate(word)
        rescue NoMethodError => e
          if e.message =~ /each_with_index/
            # known issue wth text-hyphen 1.0.0:
            # http://rubyforge.org/tracker/index.php?func=detail&aid=28128&group_id=294&atid=1195
            splits = []
          else
            raise
          end
        end

        # For each hyphenated segment, add the box with an optional hyphen.
        [0, *splits].each_cons(2) do |a, b|
          seg = word[a...b]
          tokens << box(@pdf.width_of(seg), seg)
          tokens += optional_hyphen
        end

        last = word[(splits.last || 0)..-1]
        tokens << box(@pdf.width_of(last), last)
      else
        tokens << box(@pdf.width_of(word), word)
      end

      tokens << penalty(50, 0, true) if word =~ /-$/
      tokens
    end

  end

end

