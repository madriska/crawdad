# encoding: utf-8
# GangstaWrap: Knuth-Plass linebreaking in Ruby.
#
# Copyright February 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module GangstaWrap
  Infinity = 1.0/0
end

require 'gangsta_wrap/box'
require 'gangsta_wrap/glue'
require 'gangsta_wrap/penalty'
require 'gangsta_wrap/breakpoint'
require 'gangsta_wrap/paragraph'

require 'gangsta_wrap/prawn_tokenizer'


