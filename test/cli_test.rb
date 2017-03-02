require 'helper'
require 'tmpdir'

class GitNewlineAtEof::Test < Test::Unit::TestCase
  def setup
    @tmpdir = Dir.mktmpdir
    Dir.chdir(@tmpdir)
  end
  def teardown
    unless RbConfig::CONFIG['host_os'].match(/mswin|msys|mingw|cygwin|bccwin|wince|emc/)
      FileUtils.rm(Dir.glob('*.*'))
      FileUtils.remove_entry_secure(@tmpdir)
    end
  end
  sub_test_case ' with --check-all' do
    setup do
      create_file(@tmpdir, 'file0', '')
      create_file(@tmpdir, 'file1', 'line')
      create_file(@tmpdir, 'file2', "line\n")
      create_file(@tmpdir, 'file3', "line\n\n")
      create_file(@tmpdir, 'file4', "line\n\n\n")
      create_file(@tmpdir, 'file5', "line\n\n\n\n")
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'shows warning files' do
      result = `#{cli_cmd} --check-all`
      assert_equal(1, $?.exitstatus)
      assert_equal_message(<<~EOM, result)
        file1: no newline at end of file
        file3: discarded 1 newline at end of file
        file4: discarded 2 newlines at end of file
        file5: discarded 3 newlines at end of file
      EOM
    end
  end
  sub_test_case ' with --check-all without warning' do
    setup do
      create_file(@tmpdir, 'file0', '')
      create_file(@tmpdir, 'file2', "line\n")
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'shows no messages' do
      result = `#{cli_cmd} --check-all`
      assert_equal(0, $?.exitstatus)
      assert_equal_message('', result)
    end
  end
  sub_test_case ' with --feed-last-line' do
    setup do
      create_file(@tmpdir, 'file0', 'abc')
      create_file(@tmpdir, 'file1', "line\n")
      create_file(@tmpdir, 'file2', "line\n\n")
      create_file(@tmpdir, 'file3', '')
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'fixes discarded newlines' do
      result = `#{cli_cmd} --check-all`
      assert_equal_message(<<~EOM, result)
        file0: no newline at end of file
        file2: discarded 1 newline at end of file
      EOM
      result = `#{cli_cmd} --feed-last-line`
      assert_equal('', result)
      assert_equal(0, $?.exitstatus)
      result = `#{cli_cmd} --check-all`
      assert_equal_message(<<~EOM, result)
        file2: discarded 1 newline at end of file
      EOM
    end
  end
  sub_test_case ' with --discard-last-newline' do
    setup do
      create_file(@tmpdir, 'file0', 'abc')
      create_file(@tmpdir, 'file1', "line\n")
      create_file(@tmpdir, 'file2', "line\n\n")
      create_file(@tmpdir, 'file3', '')
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'fixes no newline' do
      result = `#{cli_cmd} --check-all`
      assert_equal_message(<<~EOM, result)
        file0: no newline at end of file
        file2: discarded 1 newline at end of file
      EOM
      result = `#{cli_cmd} --discard-last-newline`
      assert_equal('', result)
      assert_equal(0, $?.exitstatus)
      result = `#{cli_cmd} --check-all`
      assert_equal_message(<<~EOM, result)
        file0: no newline at end of file
      EOM
    end
  end
  sub_test_case ' with --treat-all' do
    setup do
      create_file(@tmpdir, 'file0', 'abc')
      create_file(@tmpdir, 'file1', "line\n")
      create_file(@tmpdir, 'file2', "line\n\n")
      create_file(@tmpdir, 'file3', '')
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'fixes all' do
      result = `#{cli_cmd} --check-all`
      assert_equal_message(<<~EOM, result)
        file0: no newline at end of file
        file2: discarded 1 newline at end of file
      EOM
      result = `#{cli_cmd} --treat-all`
      assert_equal('', result)
      assert_equal(0, $?.exitstatus)
      result = `#{cli_cmd} --check-all`
      assert_equal('', result)
    end
  end
  sub_test_case ' with binary file' do
    setup do
      create_file(@tmpdir, 'file0', 'abc')
      create_file(@tmpdir, 'file1', "line\n")
      create_file(@tmpdir, 'file2', "line\n\n")
      create_file(@tmpdir, 'file3', '黒須') # multi byte char
      create_file(@tmpdir, 'file4', '白玉') # multi byte char
      create_file(@tmpdir, 'file5', (0x00..0xFF).map(&:chr).concat(["\n"] * 10).join) # binary file
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'through binary files' do
      result = `#{cli_cmd} --check-all`
      assert_equal(1, $?.exitstatus)
      assert_equal_message(<<~EOM, result)
        file0: no newline at end of file
        file2: discarded 1 newline at end of file
        file3: no newline at end of file
        file4: no newline at end of file
      EOM
    end
  end
  sub_test_case ' with non Git dir' do
    setup do
      create_file(@tmpdir, 'example', 'abc')
    end
    test 'shows error message' do
      result = `#{cli_cmd} --check-all`
      assert_equal(128, $?.exitstatus)
      assert_equal_message(<<~EOM, result)
        Here is not Git dir.
      EOM
    end
  end
  sub_test_case ' with --help' do
    test 'shows help' do
      result = `#{cli_cmd} --help`
      assert_equal(0, $?.exitstatus)
      refute_empty(result)
    end
    test 'shows help without any options' do
      result = `#{cli_cmd}`
      assert_equal(0, $?.exitstatus)
      refute_empty(result)
    end
  end
end
