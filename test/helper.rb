require 'test-unit'

def create_file(dir, filename, substance)
  filepath = File.join(dir, filename)
  File.open(filepath, 'w') do |f|
    f.write(substance)
  end
end

def cli_cmd
  File.expand_path('../../exe/git-newline-at-eof', __FILE__)
end

def assert_equal_message(result)
  assert_equal(yield, result)
end
