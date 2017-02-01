require 'git-newline-at-eof/version'
require 'optparse'

module GitNewlineAtEof
  class Application
    def initialize(argv)
      @files = files
      @is_feed_last_line = false
      @is_discard_last_newline = false
      @is_treat_all = false
      @is_check_all = false

      opt = OptionParser.new
      [
        [
          '-f', '--feed-last-line',
          'Add newline to line what is not terminated by newline at end of file.',
          proc { |v| @is_feed_last_line = true }
        ],
        [
          '-d',
          '--discard-last-newline',
          'Remove discarded newline at end of file.',
          proc { |v| @is_discard_last_newline = true }
        ],
        [
          '-a',
          '--treat-all',
          'This is identical with --feed-last-line --discard-last-newline.',
          proc { |v| @is_treat_all = true }
        ],
        [
          '-c',
          '--check-all',
          'Check and show warning about newline at end of file.',
          proc { |v| @is_check_all = true }
        ]
      ].each do |short, long, desc, proc_obj|
        opt.on(short, long, desc, &proc_obj)
      end
      opt.parse!(argv)
    end

    def run
      if @is_check_all
        check_all
      elsif @is_treat_all
        treat_all
      else
        if @is_feed_last_line
          feed_last_line_all
        end
        if @is_discard_last_newline
          discard_last_newline_all
        end
      end
    end

    def check_all
      @files.each do |f|
        if no_newline?(f[:last_newlines_num])
          puts "#{f[:filename]}: no newline at end of file"
        elsif discarded_newline?(f[:last_newlines_num])
          discarded_num = f[:last_newlines_num] - 1
          puts "#{f[:filename]}: discarded #{discarded_num} newline#{discarded_num > 1 ? 's' : ''} at end of file"
        end
      end
    end

    def treat_all
      @files.each do |f|
        if no_newline?(f[:last_newlines_num])
          feed_last_line(f[:filename])
        elsif discarded_newline?(f[:last_newlines_num])
          discard_last_newline(f[:filename], f[:last_newlines_num] - 1)
        end
      end
    end

    def feed_last_line_all
      @files.each do |f|
        if no_newline?(f[:last_newlines_num])
          feed_last_line(f[:filename])
        end
      end
    end

    def discard_last_newline_all
      @files.each do |f|
        if discarded_newline?(f[:last_newlines_num])
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

    def no_newline?(last_newlines_num)
      if last_newlines_num.nil?
        false
      elsif last_newlines_num == 0
        true
      else
        false
      end
    end
    private :no_newline?

    def discarded_newline?(last_newlines_num)
      if last_newlines_num.nil?
        false
      elsif last_newlines_num > 1
        true
      else
        false
      end
    end
    private :discarded_newline?

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
