# encoding: utf-8

puts "Running on Ruby version: #{RUBY_VERSION}"

require "rubygems"
require "test/spec"                                                
require "mocha"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib') 
require "gangsta_wrap"

# for Prawn integration
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 
                             %w[.. vendor prawn-core lib])
require 'prawn/core'

# A fast instance of Prawn::Document used only for width calculations. We
# memoize the width_of method.
#
CachedWidthDocument = (Class.new(Prawn::Document) do
  def width_of(text, options={})
    @width_cache ||= {}
    @width_cache[[text, options]] ||= super
  end
end).new

