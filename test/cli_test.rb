require 'helper'
require 'tmpdir'

class GitNewlineAtEof::Test < Test::Unit::TestCase
  def setup
    @fiber = Fiber.new do
      Dir.mktmpdir do |dir|
        Fiber.yield.call(dir)
        Fiber.yield.call(dir)
        Fiber.yield
      end
    end
    @fiber.resume
  end
  def teardown
    @fiber.resume
  end
  sub_test_case ' with --check-all' do
    setup do
      @fiber.resume(proc { |dir|
        create_file(dir, 'file0', '')
        create_file(dir, 'file1', 'line')
        create_file(dir, 'file2', "line\n")
        create_file(dir, 'file3', "line\n\n")
        create_file(dir, 'file4', "line\n\n\n")
        create_file(dir, 'file5', "line\n\n\n\n")
        Dir.chdir(dir)
        `git init`
        `git add .`
        `git commit -m 'Initial commit'`
      })
    end
    test 'requests the correct resource' do
      @fiber.resume(proc { |dir|
        result = `#{cli_cmd} --check-all`
        assert_equal_message(result) do
          <<~EOM
          file1: no newline at end of file
          file3: discarded 1 newline at end of file
          file4: discarded 2 newlines at end of file
          file5: discarded 3 newlines at end of file
          EOM
        end
      })
    end
  end
  sub_test_case ' with --feed-last-line' do
    setup do
      @fiber.resume(proc { |dir|
        create_file(dir, 'file0', 'abc')
        create_file(dir, 'file1', "line\n")
        create_file(dir, 'file2', "line\n\n")
        create_file(dir, 'file3', '')
        Dir.chdir(dir)
        `git init`
        `git add .`
        `git commit -m 'Initial commit'`
      })
    end
    test 'requests the correct resource' do
      @fiber.resume(proc { |dir|
        result = `#{cli_cmd} --check-all`
        assert_equal_message(result) do
          <<~EOM
          file0: no newline at end of file
          file2: discarded 1 newline at end of file
          EOM
        end
        result = `#{cli_cmd} --feed-last-line`
        assert_equal(result, '')
        assert_equal($?, 0)
        result = `#{cli_cmd} --check-all`
        assert_equal_message(result) do
          <<~EOM
          file2: discarded 1 newline at end of file
          EOM
        end
      })
    end
  end
  sub_test_case ' with --discard-last-newline' do
    setup do
      @fiber.resume(proc { |dir|
        create_file(dir, 'file0', 'abc')
        create_file(dir, 'file1', "line\n")
        create_file(dir, 'file2', "line\n\n")
        create_file(dir, 'file3', '')
        Dir.chdir(dir)
        `git init`
        `git add .`
        `git commit -m 'Initial commit'`
      })
    end
    test 'requests the correct resource' do
      @fiber.resume(proc { |dir|
        result = `#{cli_cmd} --check-all`
        assert_equal_message(result) do
          <<~EOM
          file0: no newline at end of file
          file2: discarded 1 newline at end of file
          EOM
        end
        result = `#{cli_cmd} --discard-last-newline`
        assert_equal(result, '')
        assert_equal($?, 0)
        result = `#{cli_cmd} --check-all`
        assert_equal_message(result) do
          <<~EOM
          file0: no newline at end of file
          EOM
        end
      })
    end
  end
  sub_test_case ' with --treat-all' do
    setup do
      @fiber.resume(proc { |dir|
        create_file(dir, 'file0', 'abc')
        create_file(dir, 'file1', "line\n")
        create_file(dir, 'file2', "line\n\n")
        create_file(dir, 'file3', '')
        Dir.chdir(dir)
        `git init`
        `git add .`
        `git commit -m 'Initial commit'`
      })
    end
    test 'requests the correct resource' do
      @fiber.resume(proc { |dir|
        result = `#{cli_cmd} --check-all`
        assert_equal_message(result) do
          <<~EOM
          file0: no newline at end of file
          file2: discarded 1 newline at end of file
          EOM
        end
        result = `#{cli_cmd} --treat-all`
        assert_equal(result, '')
        assert_equal($?, 0)
        result = `#{cli_cmd} --check-all`
        assert_equal('', result)
      })
    end
  end
end
