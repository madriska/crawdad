# encoding: utf-8
# Crawdad: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Crawdad
  Infinity = 1.0/0
end

require 'crawdad/compatibility'

require 'crawdad/box'
require 'crawdad/glue'
require 'crawdad/penalty'
require 'crawdad/breakpoint'
require 'crawdad/paragraph'

require 'crawdad/prawn_tokenizer'


