require 'test-unit'

def create_file(dir, filename)
  filepath = File.join(dir, filename)
  File.open(filepath, 'w') do |f|
    yield f if block_given?
  end
end

def cli_cmd
  File.expand_path('../../exe/git-newline-at-eof', __FILE__)
end

def assert_equal_message(result)
  assert_equal(result, yield)
end
