# Ansi::To::Html

ANSI color code sequence to HTML.

See `examples/` directory for a generated result.

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
