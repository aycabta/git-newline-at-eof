# git-newline-at-eof

## Installation

Install it yourself as:

    $ gem install git-newline-at-eof

## Description

[`POSIX.1-2008`](http://pubs.opengroup.org/onlinepubs/9699919799/) says about [definition of `Line`](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_206):

> ### 3.206 Line
> A sequence of zero or more non- \<newline\> characters plus a terminating \<newline\> character.

And also says about [definition of `Text File`](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_403):

> ### 3.403 Text File
> A file that contains characters organized into zero or more lines. The lines do not contain NUL characters and none can exceed {LINE_MAX} bytes in length, including the \<newline\> character. Although POSIX.1-2008 does not distinguish between text files and binary files (see the ISO C standard), many utilities only produce predictable or meaningful output when operating on text files. The standard utilities that have such restrictions always specify "text files" in their STDIN or INPUT FILES sections.

This Git subcommand checks and fixes newlines at end of file in your Git repository.

## Usage

### `--feed-last-line`

Add newline to line what is not terminated by newline at end of file.

```bash
$ mkdir /tmp/test
$ cd /tmp/test
$ printf "" > file0
$ printf "aaa" > file1
$ printf "bbb\n" > file2
$ git init
Initialized empty Git repository in /tmp/test/.git/
$ git add .
$ git commit -m "Initial commit"
[master (root-commit) 7c4d543] Initial commit
 3 files changed, 2 insertions(+)
 create mode 100644 file0
 create mode 100644 file1
 create mode 100644 file2
$ git newline-at-eof --feed-last-line
$ git diff
diff --git a/file1 b/file1
index 7c4a013..72943a1 100644
--- a/file1
+++ b/file1
@@ -1 +1 @@
-aaa
\ No newline at end of file
+aaa
$ git add file1
$ git commit -m "Fix last line terminator"
[master aba3275] Fix last line terminator
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Zero byte file has zero newline for termination because it has zero line.

### `--discard-last-newline`

Remove discarded newline at end of file.

```bash
$ mkdir /tmp/test
$ cd /tmp/test
$ printf "" > file0
$ printf "aaa\n" > file1
$ printf "bbb\n\n\n" > file2
$ git init
Initialized empty Git repository in /tmp/test/.git/
$ git add .
$ git commit -m "Initial commit"
[master (root-commit) 1ef005b] Initial commit
 3 files changed, 4 insertions(+)
 create mode 100644 file0
 create mode 100644 file1
 create mode 100644 file2
$ git newline-at-eof --discard-last-newline
$ git diff
diff --git a/file2 b/file2
index 6da7e67..f761ec1 100644
--- a/file2
+++ b/file2
@@ -1,3 +1 @@
 bbb
-
-
$ git add file1
$ git commit -m "Discard newlines at eof"
[master 68de945] Discard newlines at eof
 1 file changed, 2 deletions(-)
```

### `--treat-all`

This is identical with `--feed-last-line --discard-last-newline`.

### `--check-all`

Check and show warning about newline at end of file.

```bash
$ mkdir /tmp/test
$ cd /tmp/test
$ printf "" > file0
$ printf "aaa" > file1
$ printf "bbb\n" > file2
$ printf "ccc\n\n" > file3
$ printf "ddd\n\n\n" > file4
$ git init
Initialized empty Git repository in /tmp/test/.git/
$ git add .
$ git commit -m "Initial commit"
[master (root-commit) 0806035] Initial commit
 5 files changed, 7 insertions(+)
 create mode 100644 file0
 create mode 100644 file1
 create mode 100644 file2
 create mode 100644 file3
 create mode 100644 file4
$ git newline-at-eof --check-all
file1: no newline at end of file
file3: discarded 1 newline at end of file
file4: discarded 2 newlines at end of file
```

### `--help`

Help.

```bash
$ git newline-at-eof --help
Usage: git newline-at-eof [options]
    -f, --feed-last-line        Add newline to not terminated line at end of file.
    -d, --discard-last-newline  Remove discarded newline at end of file.
    -a, --treat-all             This is identical with -f -d.
    -c, --check-all             Check and show warning about newline at end of file.
    -h, --help                  Show this message.
    -v, --version               Show version.
```

## Supported Versions

- Ruby 2.3
- Ruby 2.4
- JRuby 9.1.x.x

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aycabta/git-newline-at-eof.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Badges

- [![Build Status](https://travis-ci.org/aycabta/git-newline-at-eof.svg)](https://travis-ci.org/aycabta/git-newline-at-eof)
- [![Build Status](https://ci.appveyor.com/api/projects/status/github/aycabta/git-newline-at-eof?branch=master&svg=true)](https://ci.appveyor.com/project/aycabta/git-newline-at-eof)
