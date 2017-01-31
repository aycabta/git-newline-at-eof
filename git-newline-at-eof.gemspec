# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git-newline-at-eof/version'

Gem::Specification.new do |spec|
  spec.name          = 'git-newline-at-eof'
  spec.version       = GitNewlineAtEof::VERSION
  spec.authors       = ['Code Ass']
  spec.email         = ['aycabta@gmail.com']

  spec.summary       = %q{Check and fix newline at end of file in Git respository.}
  spec.description   = %q{Check and fix newline at end of file in Git respository.}
  spec.homepage      = 'https://github.com/aycabta/git-newline-at-eof'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
