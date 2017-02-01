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

TODO: Write usage instructions here

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

[![Build Status](https://travis-ci.org/aycabta/git-newline-at-eof.svg)](https://travis-ci.org/aycabta/git-newline-at-eof)
