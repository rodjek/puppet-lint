require 'singleton'
require 'set'

# Public: A singleton class storing all the information about the manifest
# being analysed.
class PuppetLint::Data
  include Singleton

  class << self
    # Internal: Get/Set the full expanded path to the manifest file being
    # checked.
    attr_reader :path, :fullpath, :filename

    # Internal: Get/Set the raw manifest data, split by \n.
    attr_accessor :manifest_lines

    # Internal: Store the tokenised manifest.
    #
    # tokens - The Array of PuppetLint::Lexer::Token objects to store.
    #
    # Returns nothing.
    def tokens=(tokens)
      @tokens = tokens
      @title_tokens = nil
      @resource_indexes = nil
      @class_indexes = nil
      @defined_type_indexes = nil
      @node_indexes = nil
      @function_indexes = nil
      @array_indexes = nil
      @hash_indexes = nil
      @defaults_indexes = nil
    end

    def ruby1?
      @ruby1 = RbConfig::CONFIG['MAJOR'] == '1' if @ruby1.nil?
      @ruby1
    end

    # Public: Get the tokenised manifest.
    #
    # Returns an Array of PuppetLint::Lexer::Token objects.
    def tokens
      calling_method = if ruby1?
                         begin
                           caller[0][%r{`.*'}][1..-2] # rubocop:disable Performance/Caller
                         rescue NoMethodError
                           caller[1][%r{`.*'}][1..-2] # rubocop:disable Performance/Caller
                         end
                       else
                         begin
                           caller(0..0).first[%r{`.*'}][1..-2]
                         rescue NoMethodError
                           caller(1..1).first[%r{`.*'}][1..-2]
                         end
                       end

      if calling_method == 'check'
        @tokens.dup
      else
        @tokens
      end
    end

    # Public: Add new token.
    def insert(index, token)
      current_token = tokens[index - 1]
      token.next_token = current_token.next_token
      token.prev_token = current_token

      current_token.next_token.prev_token = token unless current_token.next_token.nil?

      unless formatting_tokens.include?(token.type)
        current_token.next_token.prev_code_token = token unless current_token.next_token.nil?
        next_nf_idx = tokens[index..-1].index { |r| !formatting_tokens.include?(r.type) }
        unless next_nf_idx.nil?
          next_nf_token = tokens[index + next_nf_idx]
          token.next_code_token = next_nf_token
          next_nf_token.prev_code_token = token
        end
      end

      if formatting_tokens.include?(current_token.type)
        prev_nf_idx = tokens[0..index - 1].rindex { |r| !formatting_tokens.include?(r.type) }
        unless prev_nf_idx.nil?
          prev_nf_token = tokens[prev_nf_idx]
          token.prev_code_token = prev_nf_token
          prev_nf_token.next_code_token = token
        end
      else
        token.prev_code_token = current_token
      end

      current_token.next_token = token
      unless formatting_tokens.include?(token.type)
        current_token.next_code_token = token
      end

      tokens.insert(index, token)
    end

    # Public: Removes a token
    def delete(token)
      token.next_token.prev_token = token.prev_token unless token.next_token.nil?
      token.prev_token.next_token = token.next_token unless token.prev_token.nil?
      unless formatting_tokens.include?(token.type)
        token.prev_code_token.next_code_token = token.next_code_token unless token.prev_code_token.nil?
        token.next_code_token.prev_code_token = token.prev_code_token unless token.next_code_token.nil?
      end

      tokens.delete(token)
    end

    # Internal: Store the path to the manifest file and populate fullpath and
    # filename.
    #
    # val - The path to the file as a String.
    #
    # Returns nothing.
    def path=(val)
      @path = val
      if val.nil?
        @fullpath = nil
        @filename = nil
      else
        @fullpath = File.expand_path(val, ENV['PWD'])
        @filename = File.basename(val)
      end
    end

    # Internal: Retrieve a list of tokens that represent resource titles
    #
    # Returns an Array of PuppetLint::Lexer::Token objects.
    def title_tokens
      @title_tokens ||= begin
        result = []
        tokens.each_index do |token_idx|
          if tokens[token_idx].type == :COLON
            # gather a list of tokens that are resource titles
            if tokens[token_idx - 1].type == :RBRACK
              array_start_idx = tokens.rindex do |r|
                r.type == :LBRACK
              end
              title_array_tokens = tokens[(array_start_idx + 1)..(token_idx - 2)]
              result += title_array_tokens.select do |token|
                { :STRING => true, :NAME => true }.include?(token.type)
              end
            else
              next_token = tokens[token_idx].next_code_token
              result << tokens[token_idx - 1] unless next_token.type == :LBRACE
            end
          end
        end
        result
      end
    end

    # Internal: Calculate the positions of all resource declarations within the
    # tokenised manifest. These positions only point to the content of the
    # resource declarations, they do not include resource types or titles.
    #
    # Returns an Array of Hashes, each containing:
    #   :start - An Integer position in the `tokens` Array pointing to the
    #            first Token of a resource declaration.
    #   :end   - An Integer position in the `tokens` Array pointing to the last
    #            Token of a resource declaration.
    def resource_indexes
      @resource_indexes ||= begin
        marker = 0
        result = []
        tokens.select { |t| t.type == :COLON }.each do |colon_token|
          next unless colon_token.next_code_token && colon_token.next_code_token.type != :LBRACE

          start_idx = tokens.index(colon_token)
          next if start_idx < marker
          end_token = colon_token.next_token_of([:SEMIC, :RBRACE])
          end_idx = tokens.index(end_token)

          raise PuppetLint::SyntaxError, colon_token if end_idx.nil?

          result << {
            :start        => start_idx + 1,
            :end          => end_idx,
            :tokens       => tokens[start_idx..end_idx],
            :type         => find_resource_type_token(start_idx),
            :param_tokens => find_resource_param_tokens(tokens[start_idx..end_idx]),
          }
          marker = end_idx
        end
        result
      end
    end

    # Internal: Find the Token representing the type of a resource definition.
    #
    # index - The Integer pointing to the start of the resource in the `tokens`
    #         array.
    #
    # Returns a Token object.
    def find_resource_type_token(index)
      lbrace_idx = tokens[0..index].rindex do |token|
        token.type == :LBRACE && token.prev_code_token.type != :QMARK
      end
      tokens[lbrace_idx].prev_code_token
    end

    # Internal: Find all the Token objects representing the parameter names in
    # a resource definition.
    #
    # resource_tokens - An Array of Token objects that comprise the resource
    #                   definition.
    #
    # Returns an Array of Token objects.
    def find_resource_param_tokens(resource_tokens)
      resource_tokens.select do |token|
        token.type == :NAME && token.next_code_token.type == :FARROW
      end
    end

    # Internal: Calculate the positions of all class definitions within the
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of a class definition.
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of a class definition.
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             class definition.
    def class_indexes
      @class_indexes ||= definition_indexes(:CLASS)
    end

    # Internal: Calculate the positions of all defined type definitions within
    # the `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of a defined type definition.
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of a defined type definition.
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             defined type.
    def defined_type_indexes
      @defined_type_indexes ||= definition_indexes(:DEFINE)
    end

    # Internal: Calculate the positions of all node definitions within the
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of a defined type definition.
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of a defined type definition.
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             defined type.
    def node_indexes
      @node_indexes ||= definition_indexes(:NODE)
    end

    # Internal: Calculate the positions of all the specified defintion types
    # within the `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of a definition.
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of a definition.
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             definition.
    def definition_indexes(type)
      result = []
      tokens.each_with_index do |token, i|
        next unless token.type == type

        brace_depth = 0
        paren_depth = 0
        in_params = false
        inherited_class = nil
        tokens[i + 1..-1].each_with_index do |definition_token, j|
          case definition_token.type
          when :INHERITS
            inherited_class = definition_token.next_code_token
          when :LPAREN
            in_params = true if paren_depth.zero?
            paren_depth += 1
          when :RPAREN
            in_params = false if paren_depth == 1
            paren_depth -= 1
          when :LBRACE
            brace_depth += 1
          when :RBRACE
            brace_depth -= 1
            if brace_depth.zero? && !in_params
              if token.next_code_token.type != :LBRACE
                result << {
                  :start           => i,
                  :end             => i + j + 1,
                  :tokens          => tokens[i..(i + j + 1)],
                  :param_tokens    => param_tokens(tokens[i..(i + j + 1)]),
                  :type            => type,
                  :name_token      => token.next_code_token,
                  :inherited_token => inherited_class,
                }
                break
              end
            end
          end
        end
      end
      result
    end

    # Internal: Calculate the positions of all function calls within
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of a function call
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of a function call
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             function call.
    def function_indexes
      @function_indexes ||= begin
        functions = []
        tokens.each_with_index do |token, token_idx|
          next unless token.type == :NAME
          next unless token_idx.zero? ||
                      (token_idx == 1 && tokens[0].type == :WHITESPACE) ||
                      [:NEWLINE, :INDENT].include?(token.prev_token.type) ||
                      # function in a function
                      (token.prev_code_token && token.prev_code_token.type == :LPAREN)

          # Hash key
          next if token.next_code_token && token.next_code_token.type == :FARROW

          level = 0
          real_idx = 0
          in_paren = false
          tokens[token_idx + 1..-1].each_with_index do |cur_token, cur_token_idx|
            break if level.zero? && in_paren
            break if level.zero? && cur_token.type == :NEWLINE

            if cur_token.type == :LPAREN
              level += 1
              in_paren = true
            end
            level -= 1 if cur_token.type == :RPAREN
            real_idx = token_idx + 1 + cur_token_idx
          end

          functions << {
            :start  => token_idx,
            :end    => real_idx,
            :tokens => tokens[token_idx..real_idx],
          }
        end
        functions
      end
    end

    # Internal: Calculate the positions of all array values within
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of an array value
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of an array value
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             array value.
    def array_indexes
      @array_indexes ||= begin
        arrays = []
        tokens.each_with_index do |token, token_idx|
          next unless token.type == :LBRACK

          real_idx = 0
          tokens[token_idx + 1..-1].each_with_index do |cur_token, cur_token_idx|
            real_idx = token_idx + 1 + cur_token_idx
            break if cur_token.type == :RBRACK
          end

          # Ignore resource references
          next if token.prev_code_token &&
                  token.prev_code_token.type == :CLASSREF

          arrays << {
            :start  => token_idx,
            :end    => real_idx,
            :tokens => tokens[token_idx..real_idx],
          }
        end
        arrays
      end
    end

    # Internal: Calculate the positions of all hash values within
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of an hash value
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of an hash value
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             hash value.
    def hash_indexes
      @hash_indexes ||= begin
        hashes = []
        tokens.each_with_index do |token, token_idx|
          next unless token.type == :LBRACE
          next unless token.prev_code_token
          next unless [:EQUALS, :ISEQUAL, :FARROW, :LPAREN].include?(token.prev_code_token.type)

          level = 0
          real_idx = 0
          tokens[token_idx + 1..-1].each_with_index do |cur_token, cur_token_idx|
            real_idx = token_idx + 1 + cur_token_idx

            level += 1 if cur_token.type == :LBRACE
            level -= 1 if cur_token.type == :RBRACE
            break if level < 0
          end

          hashes << {
            :start  => token_idx,
            :end    => real_idx,
            :tokens => tokens[token_idx..real_idx],
          }
        end
        hashes
      end
    end

    # Internal: Calculate the positions of all defaults declarations within
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start  - An Integer position in the `tokens` Array pointing to the
    #             first Token of the defaults declaration
    #   :end    - An Integer position in the `tokens` Array pointing to the last
    #             Token of the defaults declaration
    #   :tokens - An Array consisting of all the Token objects that make up the
    #             defaults declaration.
    def defaults_indexes
      @defaults_indexes ||= begin
        defaults = []
        tokens.each_with_index do |token, token_idx|
          next unless token.type == :CLASSREF
          next unless token.next_code_token && token.next_code_token.type == :LBRACE

          real_idx = 0

          tokens[token_idx + 1..-1].each_with_index do |cur_token, cur_token_idx|
            real_idx = token_idx + 1 + cur_token_idx
            break if cur_token.type == :RBRACE
          end

          defaults << {
            :start  => token_idx,
            :end    => real_idx,
            :tokens => tokens[token_idx..real_idx],
          }
        end
        defaults
      end
    end

    # Internal: Finds all the tokens that make up the defined type or class
    # definition parameters.
    #
    # these_tokens - An Array of PuppetLint::Lexer::Token objects that make up
    #                the defined type or class definition.
    #
    # Returns an Array of PuppetLint::Lexer::Token objects or nil if it takes
    # no parameters.
    def param_tokens(these_tokens)
      depth = 0
      lparen_idx = nil
      rparen_idx = nil

      these_tokens.each_with_index do |token, i|
        if token.type == :LPAREN
          depth += 1
          lparen_idx = i if depth == 1
        elsif token.type == :RPAREN
          depth -= 1
          if depth.zero?
            rparen_idx = i
            break
          end
        elsif token.type == :LBRACE && depth.zero?
          # no parameters
          break
        end
      end

      if lparen_idx.nil? || rparen_idx.nil?
        nil
      else
        these_tokens[(lparen_idx + 1)..(rparen_idx - 1)]
      end
    end

    # Internal: Retrieves a list of token types that are considered to be
    # formatting tokens (whitespace, newlines, etc).
    #
    # Returns an Array of Symbols.
    def formatting_tokens
      @formatting_tokens ||= PuppetLint::Lexer::FORMATTING_TOKENS
    end

    # Internal: Retrieves a Hash of Sets. Each key is a check name Symbol and
    # the Set of Integers returned lists all the lines that the check results
    # should be ignored on.
    #
    # Returns a Hash of Sets of Integers.
    def ignore_overrides
      @ignore_overrides ||= {}
    end

    # Internal: Parses all COMMENT, MLCOMMENT and SLASH_COMMENT tokens looking
    # for control comments (comments that enable or disable checks). Builds the
    # contents of the `ignore_overrides` hash.
    #
    # Returns nothing.
    def parse_control_comments
      @ignore_overrides.each_key { |check| @ignore_overrides[check].clear }

      comment_token_types = Set[:COMMENT, :MLCOMMENT, :SLASH_COMMENT]

      comment_tokens = tokens.select do |token|
        comment_token_types.include?(token.type)
      end
      control_comment_tokens = comment_tokens.select do |token|
        token.value.strip =~ %r{\Alint\:(ignore\:[\w\d]+|endignore)}
      end

      stack = []
      control_comment_tokens.each do |token|
        comment_data = []
        reason = []

        comment_words = token.value.strip.split(%r{\s+})
        comment_words.each_with_index do |word, i|
          if word =~ %r{\Alint\:(ignore|endignore)}
            comment_data << word
          else
            # Once we reach the first non-controlcomment word, assume the rest
            # of the words are the reason.
            reason = comment_words[i..-1]
            break
          end
        end

        stack_add = []

        comment_data.each do |control|
          split_control = control.split(':')
          command = split_control[1]

          if command == 'ignore'
            check = split_control[2].to_sym
            if token.prev_token && !Set[:NEWLINE, :INDENT].include?(token.prev_token.type)
              # control comment at the end of the line, override applies to
              # a single line only
              (ignore_overrides[check] ||= {})[token.line] = reason.join(' ')
            else
              stack_add << [token.line, reason.join(' '), check]
            end
          else
            top_override = stack.pop
            if top_override.nil?
              # TODO: refactor to provide a way to expose problems from
              # PuppetLint::Data via the normal problem reporting mechanism.
              puts "WARNING: lint:endignore comment with no opening lint:ignore:<check> comment found on line #{token.line}"
            else
              top_override.each do |start|
                next if start.nil?

                (start[0]..token.line).each do |i|
                  (ignore_overrides[start[2]] ||= {})[i] = start[1]
                end
              end
            end
          end
        end
        stack << stack_add unless stack_add.empty?
      end

      stack.each do |control|
        puts "WARNING: lint:ignore:#{control[0][2]} comment on line #{control[0][0]} with no closing lint:endignore comment"
      end
    end
  end
end
