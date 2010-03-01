# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

puts "Running on Ruby version: #{RUBY_VERSION}"

require "rubygems"
require "test/spec"                                                
require "mocha"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib') 
require "crawdad"

# laziness for test/spec on 1.8
include Crawdad

# for Prawn integration
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 
                             %w[.. vendor prawn lib])
require 'prawn'

# A fast instance of Prawn::Document used only for width calculations. We
# memoize the width_of method.
#
CachedWidthDocument = (Class.new(Prawn::Document) do
  def width_of(text, options={})
    @width_cache ||= {}
    @width_cache[[text, options]] ||= super
  end
end).new

