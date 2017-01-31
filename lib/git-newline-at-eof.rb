require 'git-newline-at-eof/version'

module GitNewlineAtEof
  class Application
    def initialize
    end

    def files
      `git ls-files`.split("\n").map { |filename|
        filepath = current_dir(filename)
        num = 0
        begin
          num = File.open(filepath, 'rt') { |f| count_last_newlines(f) }
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

    def repository_toplevel_dir
      `git rev-parse --show-toplevel`.chomp
    end
    private :repository_toplevel_dir

    def current_dir(filename)
      File.join(repository_toplevel_dir, `git rev-parse --show-prefix`.chomp, filename)
    end
    private :current_dir
  end
end
