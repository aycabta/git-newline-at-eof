# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git-newline-at-eof/version'

Gem::Specification.new do |spec|
  spec.name          = 'git-newline-at-eof'
  spec.version       = GitNewlineAtEof::VERSION
  spec.authors       = ['aycabta']
  spec.email         = ['aycabta@gmail.com']

  spec.summary       = %q{Check and fix newline at end of file in Git respository.}
  spec.description   = %Q{Check and fix newline at end of file in Git respository.\n}
  spec.homepage      = 'https://github.com/aycabta/git-newline-at-eof'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.3')

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'
end
