require "ansi/to/html/version"

# Based on a part of bcat
# https://github.com/rtomayko/bcat/blob/master/lib/bcat/ansi.rb

# changes:
# - \x1b[39m (and 49m) support
# - xterm256b(bgcolor for 256color) support
# - generate whole <html> with default fg/bg color (via `-f`,`-b`)

module Ansi
  module To
    class Html
      ESCAPE = "\x1b"

      # Linux console palette
      pallete = { # http://www.pixelbeat.org/scripts/ansi2html.sh
        :solarized => %w(
          073642 D30102 859900 B58900 268BD2 D33682 2AA198 EEE8D5 002B36 CB4B16 586E75 657B83 839496 6C71C4 93A1A1 FDF6E3
        ),
        :linux => %w(
          000 A00 0A0 A50 00A A0A 0AA AAA 555 F55 5F5 FF5 55F F5F 5FF FFF
        ),
        :tango => %w(
          262626 AF0000 5F8700 AF8700 0087FF AF005F 00AFAF E4E4E4 1C1C1C D75F00 585858 626262 808080 5F5FAF 8A8A8A FFFFD7
        ),
        :xterm => %w(
          000000 CD0000 00CD00 CDCD00 0000EE CD00CD 00CDCD E5E5E5 7F7F7F FF0000 00FF00 FFFF00 5C5CFF FF00FF 00FFFF FFFFFF
        ),
      }

      STYLES = {}
      PALLETE = {}
      pallete.each do |key, colors|
        PALLETE[key] = {}
        (0..15).each do |n|
          PALLETE[key]["ef#{n}"] = "color:##{colors[n]};"
          PALLETE[key]["eb#{n}"] = "background-color:##{colors[n]}"
        end
      end

      (0..5).each do |red|
        (0..5).each do |green|
          (0..5).each do |blue|
            c = 16 + (red * 36) + (green * 6) + blue
            r = red   > 0 ? red   * 40 + 55 : 0
            g = green > 0 ? green * 40 + 55 : 0
            b = blue  > 0 ? blue  * 40 + 55 : 0
            STYLES["ef#{c}"] = "color:#%2.2x%2.2x%2.2x" % [r, g, b]
            STYLES["eb#{c}"] = "background-color:#%2.2x%2.2x%2.2x" % [r, g, b]
          end
        end
      end

      (0..23).each do |gray|
        c = gray+232
        l = gray*10 + 8
        STYLES["ef#{c}"] = "color:#%2.2x%2.2x%2.2x" % [l, l, l]
        STYLES["eb#{c}"] = "background-color:#%2.2x%2.2x%2.2x" % [l, l, l]
      end

      def initialize(input)
        @input =
          if input.respond_to?(:to_str)
            [input]
          elsif !input.respond_to?(:each)
            raise ArgumentError, "input must respond to each"
          else
            input
          end
        @stack = []
      end

      def to_html(pallete = :linux)
        buf = []
        if PALLETE.keys.include?(pallete)
          @pallete = pallete
        else
          warn "--pallet=#{pallete} is unknown."
        end
        each { |chunk| buf << chunk }
        buf.join
      end

      def each
        buf = ''
        @input.each do |chunk|
          buf << chunk
          tokenize(buf) do |tok, data|
            case tok
            when :text
              yield data
            when :display
              case code = data
              when 0,39,49        ; yield reset_styles if @stack.any? # NOTE: 39/49 is reset for fg/bg color only
              when 1        ; yield push_tag("b") # bright
              when 2        ; #dim
              when 3, 4     ; yield push_tag("u")
              when 5, 6     ; yield push_tag("blink")
              when 7        ; #reverse
              when 8        ; yield push_style("display:none")
              when 9        ; yield push_tag("strike")
              when 30..37   ; yield push_style("ef#{code - 30}")
              when 40..47   ; yield push_style("eb#{code - 40}")
              when 90..97   ; yield push_style("ef#{8 + code - 90}")
              when 100..107 ; yield push_style("eb#{8 + code - 100}")
              end 
            when :xterm256f
              code = data
              yield push_style("ef#{code}")
            when :xterm256b
              code = data
              yield push_style("eb#{code}")
            end
          end
        end
        yield buf if !buf.empty?
        yield reset_styles if @stack.any?
        self
      end

      def push_tag(tag, style=nil)
        style = STYLES[style] || PALLETE[@pallete || :linux][style] if style && !style.include?(':')
        @stack.push tag
        [ "<#{tag}",
          (" style='#{style}'" if style),
          ">"
        ].join
      end

      def push_style(style)
        push_tag "span", style
      end

      def reset_styles
        stack, @stack = @stack, []
        stack.reverse.map { |tag| "</#{tag}>" }.join
      end

      def tokenize(text)
        tokens = [
          # characters to remove completely
          [/\A\x08+/, lambda { |m| '' }],

          [/\A\x1b\[38;5;(\d+)m/, lambda { |m| yield :xterm256f, $1.to_i; '' } ],
          [/\A\x1b\[48;5;(\d+)m/, lambda { |m| yield :xterm256b, $1.to_i; '' } ],

          # ansi escape sequences that mess with the display
          [/\A\x1b\[((?:\d{1,3};?)+|)m/, lambda { |m|
            m = '0' if m.strip.empty?
            m.chomp(';').split(';').
              each { |code| yield :display, code.to_i };
            '' }],

              # malformed sequences
              [/\A\x1b\[?[\d;]{0,3}/, lambda { |m| '' }],

              # real text
              [/\A([^\x1b\x08]+)/m, lambda { |m| yield :text, m; '' }]
        ]

        while (size = text.size) > 0
          tokens.each do |pattern, sub|
            break if text.sub!(pattern) { sub.call($1) }
          end
          break if text.size == size
        end
      end
    end
  end
end
