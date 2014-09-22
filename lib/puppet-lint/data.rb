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
    end

    # Public: Get the tokenised manifest.
    #
    # Returns an Array of PuppetLint::Lexer::Token objects.
    def tokens
      if caller[0][/`.*'/][1..-2] == 'check'
        @tokens.dup
      else
        @tokens
      end
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
      @title_tokens ||= Proc.new do
        result = []
        tokens.each_index do |token_idx|
          if tokens[token_idx].type == :COLON
            # gather a list of tokens that are resource titles
            if tokens[token_idx-1].type == :RBRACK
              array_start_idx = tokens.rindex { |r|
                r.type == :LBRACK
              }
              title_array_tokens = tokens[(array_start_idx + 1)..(token_idx - 2)]
              result += title_array_tokens.select { |token|
                {:STRING => true, :NAME => true}.include? token.type
              }
            else
              next_token = tokens[token_idx].next_code_token
              if next_token.type != :LBRACE
                result << tokens[token_idx - 1]
              end
            end
          end
        end
        result
      end.call
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
      @resource_indexes ||= Proc.new do
        result = []
        tokens.each_index do |token_idx|
          if tokens[token_idx].type == :COLON
            next_token = tokens[token_idx].next_code_token
            depth = 1
            if next_token.type != :LBRACE
              tokens[(token_idx + 1)..-1].each_index do |idx|
                real_idx = token_idx + idx + 1
                if tokens[real_idx].type == :LBRACE
                  depth += 1
                elsif {:SEMIC => true, :RBRACE => true}.include? tokens[real_idx].type
                  unless tokens[real_idx].type == :SEMIC && depth > 1
                    depth -= 1
                    if depth == 0
                      result << {
                        :start        => token_idx + 1,
                        :end          => real_idx,
                        :tokens       => tokens[(token_idx + 1)..real_idx],
                        :type         => find_resource_type_token(token_idx),
                        :param_tokens => find_resource_param_tokens(tokens[(token_idx + 1)..real_idx]),
                      }
                      break
                    end
                  end
                end
              end
            end
          end
        end
        result
      end.call
    end

    # Internal: Find the Token representing the type of a resource definition.
    #
    # index - The Integer pointing to the start of the resource in the `tokens`
    #         array.
    #
    # Returns a Token object.
    def find_resource_type_token(index)
      tokens[tokens[0..index].rindex { |token| token.type == :LBRACE }].prev_code_token
    end

    # Internal: Find all the Token objects representing the parameter names in
    # a resource definition.
    #
    # resource_tokens - An Array of Token objects that comprise the resource
    #                   definition.
    #
    # Returns an Array of Token objects.
    def find_resource_param_tokens(resource_tokens)
      resource_tokens.select { |token|
        token.type == :NAME && token.next_code_token.type == :FARROW
      }
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
        if token.type == type
          brace_depth = 0
          paren_depth = 0
          in_params = false
          inherited_class = nil
          tokens[i+1..-1].each_with_index do |definition_token, j|
            case definition_token.type
            when :INHERITS
              inherited_class = definition_token.next_code_token
            when :LPAREN
              in_params = true if paren_depth == 0
              paren_depth += 1
            when :RPAREN
              in_params = false if paren_depth == 1
              paren_depth -= 1
            when :LBRACE
              brace_depth += 1
            when :RBRACE
              brace_depth -= 1
              if brace_depth == 0 && !in_params
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
      end
      result
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
          if depth == 0
            rparen_idx = i
            break
          end
        elsif token.type == :LBRACE && depth == 0
          # no parameters
          break
        end
      end

      if lparen_idx.nil? or rparen_idx.nil?
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
      control_re = /\A(lint:\S+)(\s+lint:\S+)*(.*)/

      comment_token_types = Set[:COMMENT, :MLCOMMENT, :SLASH_COMMENT]

      comment_tokens = tokens.select { |token|
        comment_token_types.include?(token.type)
      }
      control_comment_tokens = comment_tokens.select { |token|
        token.value.strip =~ /\Alint:(ignore:[\w\d]+|endignore)/
      }

      stack = []
      control_comment_tokens.each do |token|
        comment_data = control_re.match(token.value.strip).to_a[1..-1].compact.map(&:strip)
        if comment_data.last =~ /\Alint:(ignore|endignore)/
          comment_data << ''
        end
        reason = comment_data.pop
        stack_add = []
        comment_data.each do |control|
          split_control = control.split(':')
          command = split_control[1]

          if command == 'ignore'
            check = split_control[2].to_sym

            if token.prev_token && !Set[:NEWLINE, :INDENT].include?(token.prev_token.type)
              # control comment at the end of the line, override applies to
              # a single line only
              (ignore_overrides[check] ||= {})[token.line] = reason
            else
              stack_add << [token.line, reason, check]
            end
          else
            stack.pop.each do |start|
              unless start.nil?
                (start[0]..token.line).each do |i|
                  (ignore_overrides[start[2]] ||= {})[i] = start[1]
                end
              end
            end
          end
        end
        stack << stack_add unless stack_add.empty?
      end
    end
  end
end
