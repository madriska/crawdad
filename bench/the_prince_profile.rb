# encoding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w[.. lib])) 
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w[.. vendor prawn lib])) 

require "prawn"
require 'ruby-prof'

require_relative 'the_prince/documents'

# puts "Profiling Ruby..."
# ruby_result = RubyProf.profile do
#   RubyDoc.generate("the_prince_ruby.pdf", :compress => true, &$doc)
# end
# printer = RubyProf::GraphHtmlPrinter.new(ruby_result)
# File.open("ruby_profile.html", "w") { |f| printer.print(f, :min_percent => 0) }


puts "Profiling FFI..."
require 'crawdad/ffi'
ffi_result = RubyProf.profile do
  RubyDoc.generate("the_prince_ffi.pdf", :compress => true, &$doc)
end
printer = RubyProf::GraphHtmlPrinter.new(ffi_result)
File.open("ffi_profile.html", "w") { |f| printer.print(f, :min_percent => 0) }

