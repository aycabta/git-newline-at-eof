require 'git-newline-at-eof/version'
require 'optparse'
require 'shellwords'
require 'open3'

module GitNewlineAtEof
  class Application
    def initialize(argv)
      @in_git_dir = nil
      @options = {}
      @options[:feed_last_line] = false
      @options[:discard_last_newline] = false
      @options[:treat_all] = false
      @options[:check_all] = false
      @options[:help] = false
      @options[:opted] = false

      @opt = OptionParser.new
      [
        [
          '-f', '--feed-last-line',
          'Add newline to not terminated line at end of file.',
          proc { |v|
            @options[:feed_last_line] = true
            @options[:opted] = true
          }
        ],
        [
          '-d',
          '--discard-last-newline',
          'Remove discarded newline at end of file.',
          proc { |v|
            @options[:discard_last_newline] = true
            @options[:opted] = true
          }
        ],
        [
          '-a',
          '--treat-all',
          'This is identical with -f -d.',
          proc { |v|
            @options[:treat_all] = true
            @options[:opted] = true
          }
        ],
        [
          '-c',
          '--check-all',
          'Check and show warning about newline at end of file.',
          proc { |v|
            @options[:check_all] = true
            @options[:opted] = true
          }
        ],
        [
          '-h',
          '--help',
          'Show this message.',
          proc { |v|
            @options[:help] = true
            @options[:opted] = true
          }
        ],
        [
          '-v',
          '--version',
          'Show version.',
          proc {
            @options[:opted] = true
            puts @opt.ver
          }
        ]
      ].each do |short, long, desc, proc_obj|
        @opt.on(short, long, desc, &proc_obj)
      end
      @opt.program_name = 'git newline-at-eof'
      @opt.version = GitNewlineAtEof::VERSION
      @opt.summary_width = 27
      @opt.parse!(argv)
    end

    def run # return value is used for exit status
      if !@options[:opted] || @options[:help]
        puts @opt.help
        0
      elsif !in_git_dir?
        puts 'Here is not Git dir.'
        128
      else
        @files = files
        if @options[:check_all]
          case check_all
          when :clean
            0
          when :warning
            1
          end
        elsif @options[:treat_all]
          treat_all
          0
        else
          if @options[:feed_last_line]
            feed_last_line_all
          end
          if @options[:discard_last_newline]
            discard_last_newline_all
          end
          0
        end
      end
    end

    def in_git_dir?
      if !@in_git_dir.nil?
        @in_git_dir
      else
        o, e, exit_status = Open3.capture3('git rev-parse')
        if exit_status == 0
          @in_git_dir = true
        else
          @in_git_dir = false
        end
      end
    end

    def check_all
      exist_warning = false
      @files.each do |f|
        if no_newline?(f[:last_newlines_num])
          exist_warning = true
          puts "#{f[:filename]}: no newline at end of file"
        elsif discarded_newline?(f[:last_newlines_num])
          exist_warning = true
          discarded_num = f[:last_newlines_num] - 1
          puts "#{f[:filename]}: discarded #{discarded_num} newline#{discarded_num > 1 ? 's' : ''} at end of file"
        end
      end
      if exist_warning
        :warning
      else
        :clean
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

    private def feed_last_line(filename)
      filepath = current_dir(filename)
      File.open(filepath, 'at') do |f|
        f.write("\n")
      end
    end

    private def discard_last_newline(filename, discard_num)
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

    private def no_newline?(last_newlines_num)
      if last_newlines_num.nil?
        false
      elsif last_newlines_num == 0
        true
      else
        false
      end
    end

    private def discarded_newline?(last_newlines_num)
      if last_newlines_num.nil?
        false
      elsif last_newlines_num > 1
        true
      else
        false
      end
    end

    private def files
      `git ls-files`.split("\n").select{ |filename|
        # check text file
        `git grep -I --name-only --untracked -e . -- #{Shellwords.shellescape(filename)}`
        $? == 0
      }.map { |filename|
        filepath = current_dir(filename)
        num = 0
        begin
          num = File.open(filepath, 'rb') { |f| count_last_newlines(f) }
        rescue
          num = nil
        end
        {
          filename: filename,
          last_newlines_num: num
        }
      }
    end

    private def count_last_newlines(f)
      if f.size == 0
        nil
      else
        prev_char = nil
        count = 0
        f.size.step(1, -1) do |offset|
          offset -= 1
          f.seek(offset, IO::SEEK_SET)
          if (c = f.getc) == "\n"
            count += 1
            prev_char = c
          elsif c == "\r"
            unless prev_char == "\n"
              count += 1
            end
            prev_char = c
          else
            break
          end
        end
        count
      end
    end

    private def repository_toplevel_dir
      `git rev-parse --show-toplevel`.chomp
    end

    private def current_dir(filename)
      File.join(repository_toplevel_dir, `git rev-parse --show-prefix`.chomp, filename)
    end
  end
end
