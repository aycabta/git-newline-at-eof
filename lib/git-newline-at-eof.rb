require 'git-newline-at-eof/version'
require 'git'

module GitNewlineAtEof
  class Manager
    def initialize
      @git = Git.open('.')
    end

    def files
      @git.ls_files.delete_if { |file|
        file.nil? || !file.instance_of?(String)
      }.map { |file|
        filename = file.first
        num = 0
        begin
          num = File.open(filename, 'rt') { |f| count_last_newlines(f) }
        rescue
          num = nil
        end
        {
          filename: filename,
          last_newlines_num: num
        }
      }
    end

    def count_last_newlines(f)
      if f.size == 0
        nil
      else
        count = 0
        f.size.step(1, -1) do |offset|
          offset -= 1
          f.seek(offset, IO::SEEK_SET)
          if f.getc == "\n"
            count += 1
          else
            break
          end
        end
        count
      end
    end
    private :count_last_newlines
  end
end
