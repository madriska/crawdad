require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

CRAWDAD_VERSION = '0.0.1'

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

spec = Gem::Specification.new do |spec|
  spec.name = 'crawdad'
  spec.version = CRAWDAD_VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Knuth-Plass linebreaking for Ruby"
  spec.files = FileList["lib/**/**/*"] + FileList["ext/crawdad/*"]
  spec.require_paths << 'ext'

  binaries = FileList['ext/crawdad/*.bundle', 'ext/crawdad/*.so']
  spec.extensions << 'Rakefile'
  spec.files += binaries.to_a

  spec.has_rdoc = true
  spec.rdoc_options << '--title' << 'Crawdad Documentation' << '-q'
  spec.author = 'Brad Ediger'
  spec.email = 'brad.ediger@madriska.com'
  spec.homepage = 'http://github.com/madriska/crawdad'
  spec.description = <<END_DESC
  Crawdad is an implementation of Knuth-Plass linebreaking (justification)
  for Ruby.
END_DESC
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

