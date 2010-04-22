require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

# Build must be the default task, to fake out using a Makefile to build a
# non-Ruby extension with Rubygems. There's probably an easier way, but I can't
# find it.
task :default => [:build]
task :build do
  system "make -Cext/crawdad"
end
       
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

spec = Gem::Specification.load("crawdad.gemspec")
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

