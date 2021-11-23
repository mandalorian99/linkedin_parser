require_relative 'lib/linkedin_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "linkedin_parser"
  spec.version       = LinkedinParser::VERSION
  spec.authors       = ["Mahendra Choudhary"]
  spec.email         = ["mahendrachoudhary1156@gmail.com"]

  spec.summary       = %q{a ruby gem to parse linkedin emails resumes}
  spec.description   = %q{A linkedin resume parser to parse incoming linkedin html emails}
  spec.homepage      = "https://github.com/mandalorian99/linkedin_parser"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mandalorian99/linkedin_parser.git"
  spec.metadata["changelog_uri"] = "https://github.com/mandalorian99/linkedin_parser/blob/master/CODE_OF_CONDUCT.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
