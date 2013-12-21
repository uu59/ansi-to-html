# Ansi::To::Html

ANSI color code sequence to HTML.

See <http://uu59.github.io/ansi-to-html/index.html> for a generated result.

This is almost deadcopy of [bcat](https://github.com/rtomayko/bcat/blob/master/lib/bcat/ansi.rb) :bow:

But some differences are:

- `\x1b[39m` (and `49m`) support
- bgcolor for 256color support
- generate whole `<html>` with default fg/bg color (via `-f`,`-b`)

## Installation

Add this line to your application's Gemfile:

    gem 'ansi-to-html'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ansi-to-html

## Usage

    $ tmux capture-pane -S -10000  -e; tmux show-buffer > /tmp/terminal
    $ ansi-to-html /tmp/terminal > /tmp/foo.html
    $ cat /tmp/terminal | ansi-to-html > /tmp/bar.html
    $ tmux capture-pane -S -10000  -e; tmux show-buffer | ansi-to-html > /tmp/baz.html

Specify default foreground/background color with `-f` and/or `-b` option such as `ansi-to-html -f '#fff' -b '#000'`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
