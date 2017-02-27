class PuppetLint
  class Lexer
    # Public: Stores a fragment of the manifest and the information about its location in the
    # manifest.
    class Token
      class AssertionError < RuntimeError
      end
      # Public: Returns the Symbol type of the Token.
      attr_accessor :type

      # Public: Returns the String value of the Token.
      attr_accessor :value

      # Public: Returns the raw value of the Token.
      attr_accessor :raw

      # Public: Returns the Integer line number of the manifest text where the Token can be found.
      attr_accessor :line

      # Public: Returns the Integer column number of the line of the manifest text where the Token
      # can be found.
      attr_accessor :column

      # Public: Gets/sets the next token in the manifest.
      attr_reader :next_token

      def width
        return @value.length
      end

      def height
        if @type == :NEWLINE then
          return 1
        elsif [:WHITESPACE, :COMMENT, :SLASH_COMMENT, :MLCOMMENT, :INDENT].include?(@type) then
          return @value.lines.length - 1
        else
          return 0
        end
      end

      def __next_token=(val)
        @next_token = val

        # Walk to the right, updating line and column info
        prev = self
        until val.nil? do
          nl = prev.line + prev.height
          nc = prev.type == :NEWLINE ? 1 : prev.column + prev.width
          if nl == val.line and nc == val.column then
            break
          else
            val.line = nl
            val.column = nc
            prev = val
            val = val.next_token
          end
        end
      end

      def next_token=(val)
        if(val != @next_token) then
          t = @next_token
          @next_token = val
          unless val.nil?
            val.__prev_token = self
            val.__next_token = t
          end
          unless t.nil?
            t.__prev_token = val
          end
        end
      end

      # Public: Gets/sets the previous token in the manifest.
      attr_reader :prev_token

      def __prev_token=(val)
        @prev_token = val
        unless val.nil?
          @line = val.line + val.height
          @column = val.type == :NEWLINE ? 1 : val.column + val.width
          self.__next_token = @next_token # to force line/pos recomputation
        end
      end

      def prev_token=(val)
        if(val != @prev_token)
          t = @prev_token
          @prev_token = val
          unless t.nil?
            t.__next_token = val
          end
          unless val.nil?
            val.__next_token = self
            val.__prev_token = t
          end
        end
      end

      # Public: Gets the next code token (skips whitespace, comments, etc) in the manifest.
      def next_code_token
        t = @next_token
        while t and t.whitespace?
          t = t.next_token
        end
        return t
      end

      # Public: Gets the previous code token (skips whitespace, comments, etc) in the manifest.
      def prev_code_token
        t = @prev_token
        while t and t.whitespace?
          t = t.prev_token
        end
        return t
      end

      # Public: Takes a token which is farther down the chain to the right (this is covered by an
      # assert), and unlinks the sublist between this token and the given end token from the
      # list. The list is correctly spliced so that the preceding and following tokens are now
      # sequential.
      def slice_to(other)
        cur = self
        while not cur.nil? and cur != other do
          cur = cur.next_token
        end
        if cur.nil? then
          raise AssertionError
        end

        self.prev_token.next_token = nil
        other.next_token.prev_token = @prev_token
        @prev_token = nil
        other.next_token = nil
        return self
      end

      # Public: Inserts a new sublist being whatever is between the argument start and end tokens
      # _after_ the current token in the tokens list.
      def splice_in(start_t, end_t)
        @next_token.prev_token = end_t
        start_t.prev_token = self
      end

      # Public: Returns the array form of the entire token chain to the right of this token.
      #
      # Users should prefer the above linked list slice and splice operations to manipulating arrays
      # of tokens.
      def to_array
        arr = []
        cur = self
        while not cur.nil?
          arr << cur
          cur = cur.next_token
        end
        return arr
      end

      # Public: Builds the token chain from an array of tokens.
      #
      # Users should prefer the above linked list slice and splice operations to manipulating arrays
      # of tokens.
      class << self
        def from_array(arr)
          prev = nil
          arr.each do |e|
            e.prev_token = prev
            prev = e
          end
          return arr.first
        end
      end

      # Public: Initialise a new Token object.
      #
      # type   - An upper case Symbol describing the type of Token.
      # value  - The String value of the Token.
      # line   - The Integer line number where the Token can be found in the manifest.
      # column - The Integer number of characters from the start of the line to the start of the
      #          Token.
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

      # Public: Produce a human friendly description of the Token when inspected.
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
          if !prev_code_token.nil? && [:DQPRE, :DQMID].include?(prev_code_token.type)
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

      def whitespace?
        return PuppetLint::Lexer::FORMATTING_TOKENS.fetch(@type, false)
      end
    end
  end
end
