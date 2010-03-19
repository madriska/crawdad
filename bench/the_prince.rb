# encoding: utf-8
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w[.. lib])) 
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), %w[.. vendor prawn lib])) 

require "prawn"
require "benchmark"

require "#{File.dirname(__FILE__)}/the_prince/documents"

Benchmark.bm(10) do |bm|

  bm.report("naive") do
    NaiveDoc.generate("the_prince_naive.pdf", :compress => true, &$doc)
  end

  bm.report("ruby") do
    RubyDoc.generate("the_prince_ruby.pdf", :compress => true, &$doc)
  end

  require 'crawdad/ffi'
  bm.report("ffi") do
    RubyDoc.generate("the_prince_ffi.pdf", :compress => true, &$doc)
  end

end
