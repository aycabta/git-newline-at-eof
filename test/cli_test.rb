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
    test 'requests the correct resource' do
      result = `#{cli_cmd} --check-all`
      assert_equal_message(result) do
        <<~EOM
        file1: no newline at end of file
        file3: discarded 1 newline at end of file
        file4: discarded 2 newlines at end of file
        file5: discarded 3 newlines at end of file
        EOM
      end
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
    test 'requests the correct resource' do
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
    test 'requests the correct resource' do
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
    test 'requests the correct resource' do
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
    end
  end
  sub_test_case ' with binary file' do
    setup do
      create_file(@tmpdir, 'file0', 'abc')
      create_file(@tmpdir, 'file1', "line\n")
      create_file(@tmpdir, 'file2', "line\n\n")
      create_file(@tmpdir, 'file3', '黒須') # multi byte char
      create_file(@tmpdir, 'file4', '白玉') # multi byte char
      create_file(@tmpdir, 'file5', (0x00..0xFF).map(&:chr).concat(["\n"] * 10).join)
      `git init`
      `git add .`
      `git commit -m 'Initial commit'`
    end
    test 'requests the correct resource' do
      result = `#{cli_cmd} --check-all`
      assert_equal_message(result) do
        <<~EOM
        file0: no newline at end of file
        file2: discarded 1 newline at end of file
        file3: no newline at end of file
        file4: no newline at end of file
        EOM
      end
    end
  end
end
