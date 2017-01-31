require 'git-newline-at-eof/version'

module GitNewlineAtEof
  class Application
    def initialize
      @files = files
    end

    def check_all
      @files.each do |f|
        if f[:last_newlines_num] == 0
          puts "#{f[:filename]}: no newline at end of file"
        end
        if f[:last_newlines_num] > 1
          discarded_num = f[:last_newlines_num] - 1
          puts "#{f[:filename]}: discarded #{discarded_num} newline#{discarded_num > 1 ? 's' : ''} at end of file"
        end
      end
    end

    def treat_all
      @files.each do |f|
        if f[:last_newlines_num] == 0
          feed_last_line(f[:filename])
        end
        if f[:last_newlines_num] > 1
          discard_last_newline(f[:filename], f[:last_newlines_num] - 1)
        end
      end
    end

    def feed_last_line_all
      @files.each do |f|
        if f[:last_newlines_num] == 0
          feed_last_line(f[:filename])
        end
      end
    end

    def discard_last_newline_all
      @files.each do |f|
        if f[:last_newlines_num] > 1
          discard_last_newline(f[:filename], f[:last_newlines_num] - 1)
        end
      end
    end

    def feed_last_line(filename)
      filepath = current_dir(filename)
      File.open(filepath, 'at') do |f|
        f.write("\n")
      end
    end
    private :feed_last_line

    def discard_last_newline(filename, discard_num)
      filepath = current_dir(filename)
      lines = nil
      File.open(filepath, 'rt') do |f|
        lines = f.readlines
      end
      File.open(filepath, 'wt') do |f|
        lines[0, lines.size - discard_num].each do |l|
          f.write(l)
        end
      end
    end
    private :discard_last_newline

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
    private :files

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
