# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'crawdad/native'

begin
  require 'crawdad/ffi'
rescue LoadError
end

if defined?(Prawn)
  require 'crawdad/prawn_tokenizer'
end

