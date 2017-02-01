require 'helper'
require 'tmpdir'

class GitNewlineAtEof::Test < Test::Unit::TestCase
  def setup
    @tmpdir = Dir.mktmpdir
  end
  def teardown
    FileUtils.remove_entry_secure(@tmpdir)
  end
  sub_test_case ' with --feed-last-line' do
    setup do
      create_file(@tmpdir, 'file0', 'abc')
      create_file(@tmpdir, 'file1', "line\n")
      create_file(@tmpdir, 'file2', "line\n\n")
      create_file(@tmpdir, 'file3', '')
      Dir.chdir(@tmpdir)
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
end