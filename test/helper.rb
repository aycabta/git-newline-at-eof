require 'test-unit'
require 'shellwords'

def create_file(dir, filename, substance)
  filepath = File.join(dir, filename)
  File.open(filepath, 'w') do |f|
    f.write(substance)
  end
end

def cli_cmd
  expanded_path = File.expand_path('../../exe/git-newline-at-eof', __FILE__)
  "ruby #{Shellwords.escape(expanded_path)}"
end

def assert_equal_message(message, result)
  assert_equal(message, result)
end
