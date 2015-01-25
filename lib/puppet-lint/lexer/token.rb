class PuppetLint
  class Lexer
    # Public: Stores a fragment of the manifest and the information about its
    # location in the manifest.
    class Token
      # Public: Returns the Symbol type of the Token.
      attr_accessor :type

      # Public: Returns the String value of the Token.
      attr_accessor :value

      # Public: Returns the raw value of the Token.
      attr_accessor :raw

      # Public: Returns the Integer line number of the manifest text where
      # the Token can be found.
      attr_reader :line

      # Public: Returns the Integer column number of the line of the manifest
      # text where the Token can be found.
      attr_reader :column

      # Public: Gets/sets the next token in the manifest.
      attr_accessor :next_token

      # Public: Gets/sets the previous token in the manifest.
      attr_accessor :prev_token

      # Public: Gets/sets the next code token (skips whitespace, comments,
      # etc) in the manifest.
      attr_accessor :next_code_token

      # Public: Gets/sets the previous code tokne (skips whitespace,
      # comments, etc) in the manifest.
      attr_accessor :prev_code_token

      # Public: Initialise a new Token object.
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
        @next_token = nil
        @prev_token = nil
        @next_code_token = nil
        @prev_code_token = nil
      end

      # Public: Produce a human friendly description of the Token when
      # inspected.
      #
      # Returns a String describing the Token.
      def inspect
        "<Token #{@type.inspect} (#{@value}) @#{@line}:#{@column}>"
      end

      # Public: Produce a Puppet DSL representation of a Token.
      #
      # Returns a Puppet DSL String.
      def to_manifest
        case @type
        when :STRING
          "\"#{@value}\""
        when :SSTRING
          "'#{@value}'"
        when :DQPRE
          "\"#{@value}"
        when :DQPOST
          "#{@value}\""
        when :VARIABLE
          if !@prev_code_token.nil? && [:DQPRE, :DQMID].include?(@prev_code_token.type)
            "${#{@value}}"
          else
            "$#{@value}"
          end
        when :UNENC_VARIABLE
          "$#{@value}"
        when :NEWLINE
          "\n"
        when :COMMENT
          "##{@value}"
        when :REGEX
          "/#{@value}/"
        when :MLCOMMENT
          @raw
        else
          @value
        end
      end
    end
  end
end
