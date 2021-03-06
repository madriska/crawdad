Gem::Specification.new do |spec|
  spec.name = 'crawdad'
  spec.version = '0.1.0'
  spec.platform = Gem::Platform::RUBY
  spec.summary = "Knuth-Plass linebreaking for Ruby"
  spec.files = FileList["lib/**/**/*", "ext/crawdad/*", "README.markdown",
		"crawdad.gemspec", "CHANGELOG"]
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

