require_relative 'lib/lazy/check/version'

Gem::Specification.new do |s|
  s.name          = "lazy-check"
  s.version       = Lazy::Check::VERSION
  s.authors       = ["PhilippePerret"]
  s.email         = ["philippe.perret@yahoo.fr"]

  s.summary       = %q{Vérification paresseuse d'un site web}
  s.description   = %q{Ce gem permet de façon paresseuse mais néanmoins sérieuse de tester qu'un site web est valide au niveau de ses pages et de son contenu.}
  s.homepage      = "https://rubygems.org/gems/lazy-check"
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-color'

  s.add_dependency 'clir'
  s.add_dependency 'nokogiri'

  s.metadata["allowed_push_host"] = "https://rubygems.org"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/PhilippePerret/gem-lazy-check"
  s.metadata["changelog_uri"] = "https://github.com/PhilippePerret/gem-lazy-check/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
