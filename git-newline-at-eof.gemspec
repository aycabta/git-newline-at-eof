# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git-newline-at-eof/version'

Gem::Specification.new do |spec|
  spec.name          = 'git-newline-at-eof'
  spec.version       = GitNewlineAtEof::VERSION
  spec.authors       = ['Code Ass']
  spec.email         = ['aycabta@gmail.com']

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'TODO: Put your gem\'s website or public repo URL here.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'git'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
