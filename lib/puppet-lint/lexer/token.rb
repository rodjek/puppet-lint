class PuppetLint
  class Lexer
    class Token
      attr_reader :type, :value, :line, :column

      def initialize(type, value, line, column)
        @value = value
        @type = type
        @line = line
        @column = column
      end

      def inspect
        "<Token #{@type.inspect} (#{@value}) @#{@line}:#{@column}>"
      end
    end
  end
end
