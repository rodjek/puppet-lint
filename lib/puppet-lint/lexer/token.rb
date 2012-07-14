class PuppetLint
  class Lexer
    class Token
      attr_reader :type, :value, :line, :column

      # Internal: Initialise a new Token object.
      #
      # type   - An upper case Symbol describing the type of Token.
      # value  - The String value of the Token.
      # line   - The Integer line number where the Token can be found in the
      #          manifest.
      # column - The Integer number of characters from the start of the line to
      #          the start of the Token.
      #
      # Returns the instantiated Token.
      def initialize(type, value, line, column)
        @value = value
        @type = type
        @line = line
        @column = column
      end

      # Internal: Produce a human friendly description of the Token when
      # inspected.
      #
      # Returns a String describing the Token.
      def inspect
        "<Token #{@type.inspect} (#{@value}) @#{@line}:#{@column}>"
      end
    end
  end
end
