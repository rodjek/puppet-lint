require 'strscan'

class PuppetLint
  class Lexer
    # Document this
    # TODO
    class StringSlurper
      class UnterminatedStringError < StandardError; end

      attr_accessor :scanner
      attr_accessor :results
      attr_accessor :interp_stack

      START_INTERP_PATTERN = %r{\$\{}
      END_INTERP_PATTERN = %r{\}}
      END_STRING_PATTERN = %r{(\A|[^\\])(\\\\)*"}
      UNENC_VAR_PATTERN = %r{(\A|[^\\])\$(::)?(\w+(-\w+)*::)*\w+(-\w+)*}
      ESC_DQUOTE_PATTERN = %r{\\+"}

      def initialize(string)
        @scanner = StringScanner.new(string)
        @results = []
        @interp_stack = []
        @segment = []
      end

      def parse
        until scanner.eos?
          if scanner.match?(START_INTERP_PATTERN)
            start_interp
          elsif scanner.match?(END_INTERP_PATTERN)
            end_interp
          elsif interp_stack.empty? && scanner.match?(UNENC_VAR_PATTERN)
            unenclosed_variable
          elsif scanner.match?(ESC_DQUOTE_PATTERN)
            @segment << scanner.scan(ESC_DQUOTE_PATTERN)
          elsif scanner.match?(END_STRING_PATTERN)
            end_string
            break if interp_stack.empty?
          else
            read_char
          end
        end

        raise UnterminatedStringError if results.empty? && scanner.matched?

        results
      end

      def read_char
        @segment << scanner.getch
      end

      def consumed_bytes
        scanner.pos
      end

      def start_interp
        if interp_stack.empty?
          scanner.skip(START_INTERP_PATTERN)
          results << [:STRING, @segment.join]
          @segment = []
        else
          @segment << scanner.scan(START_INTERP_PATTERN)
        end

        interp_stack.push(true)
      end

      def end_interp
        interp_stack.pop unless interp_stack.empty?

        if interp_stack.empty?
          results << [:INTERP, @segment.join]
          @segment = []
          scanner.skip(END_INTERP_PATTERN)
        else
          @segment << scanner.scan(END_INTERP_PATTERN)
        end
      end

      def unenclosed_variable
        read_char if scanner.match?(%r{.\$})

        results << [:STRING, @segment.join]
        results << [:UNENC_VAR, scanner.scan(UNENC_VAR_PATTERN)]
        @segment = []
      end

      def end_string
        if interp_stack.empty?
          @segment << scanner.scan(END_STRING_PATTERN).gsub!(%r{"\Z}, '')
          results << [:STRING, @segment.join]
        else
          @segment << scanner.scan(END_STRING_PATTERN)
        end
      end
    end
  end
end
