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
          enclose_token_types = Set[:DQPRE, :DQMID, :HEREDOC_PRE, :HEREDOC_MID].freeze
          if !@prev_code_token.nil? && enclose_token_types.include?(@prev_code_token.type)
            if @raw.nil?
              "${#{@value}}"
            else
              "${#{@raw}}"
            end
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
        when :HEREDOC_OPEN
          "@(#{@value})"
        when :HEREDOC
          @raw
        when :HEREDOC_POST
          @raw
        else
          @value
        end
      end

      # Public: Search from this token to find the next token of a given type.
      #
      # type - A Symbol type of the token to find, or an Array of Symbols.
      # opts - An optional Hash
      #   :value       - A token value to search for in addition to type
      #   :skip_blocks - A Boolean to specify whether { } blocks should be
      #                  skipped over (defaults to true).
      #
      # Returns a PuppetLint::Lexer::Token object if a matching token could be
      # found, otherwise nil.
      def next_token_of(type, opts = {})
        find_token_of(:next, type, opts)
      end

      # Public: Search from this token to find the previous token of a given type.
      #
      # type - A Symbol type of the token to find, or an Array of Symbols.
      # opts - An optional Hash
      #   :value       - A token value to search for in addition to type
      #   :skip_blocks - A Boolean to specify whether { } blocks should be
      #                  skipped over (defaults to true).
      #
      # Returns a PuppetLint::Lexer::Token object if a matching token could be
      # found, otherwise nil.
      def prev_token_of(type, opts = {})
        find_token_of(:prev, type, opts)
      end

      # Internal: Search from this token to find the next token of a given type
      # in a given direction.
      #
      # direction - A Symbol direction to search (:next or :prev).
      # type      - A Symbol type of the token to find, or an Array of Symbols.
      # opts      - An optional Hash
      #   :value       - A token value to search for in addition to type
      #   :skip_blocks - A Boolean to specify whether { } blocks should be
      #                  skipped over (defaults to true).
      #
      # Returns a PuppetLint::Lexer::Token object if a matching token could be
      # found, otherwise nil.
      def find_token_of(direction, type, opts = {})
        return nil unless [:next, :prev].include?(direction)

        opts[:skip_blocks] ||= true
        to_find = Array[*type]

        token_iter = self.send("#{direction}_token".to_sym)
        while !token_iter.nil?
          if to_find.include? token_iter.type
            if opts[:value]
              return token_iter if token_iter.value == opts[:value]
            else
              return token_iter
            end
          end

          opening_token = direction == :next ? "L" : "R"
          closing_token = direction == :next ? "R" : "L"

          if opts[:skip_blocks]
            case token_iter.type
            when "#{opening_token}BRACE".to_sym
              token_iter = token_iter.send("#{direction}_token_of".to_sym, ["#{closing_token}BRACE".to_sym, opts])
            when "#{opening_token}BRACK".to_sym
              token_iter = token_iter.send("#{direction}_token_of".to_sym, ["#{closing_token}BRACK".to_sym, opts])
            when "#{opening_token}PAREN".to_sym
              token_iter = token_iter.send("#{direction}_token_of".to_sym, ["#{closing_token}PAREN".to_sym, opts])
            end
          end
          token_iter = token_iter.send("#{direction}_token".to_sym)
        end
        nil
      end
    end
  end
end
