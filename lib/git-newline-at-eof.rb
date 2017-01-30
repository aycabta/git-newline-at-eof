require 'git-newline-at-eof/version'
require 'git'

module GitNewlineAtEof
  class Manager
    def initialize
      @git = Git.open('.')
    end
  end
end
