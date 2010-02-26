require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => [:test]
       
desc "Run all tests, test-spec required"
Rake::TestTask.new do |test|
  test.libs       << "spec"
  test.test_files =  Dir[ "spec/*_spec.rb" ]
  test.verbose    =  true
end

desc "Generate documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include("README", "lib/")
  rdoc.main     = "README"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "Crawdad Documentation"
end     

