require 'singleton'

class PuppetLint::Data
  include Singleton

  class << self
    attr_reader :tokens

    # Internal: Get/Set the full expanded path to the manifest file being
    # checked.
    attr_accessor :fullpath

    # Internal: Get/Set the raw manifest data, split by \n.
    attr_accessor :manifest_lines

    def tokens=(tokens)
      @tokens = tokens
      @title_tokens = nil
      @resource_indexes = nil
      @class_indexes = nil
      @defined_type_indexes = nil
    end

    # Internal: Retrieve a list of tokens that represent resource titels
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
                      result << {:start => token_idx + 1, :end => real_idx}
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

    # Internal: Calculate the positions of all class definitions within the
    # `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start - An Integer position in the `tokens` Array pointing to the
    #            first Token of a class definition.
    #   :end   - An Integer position in the `tokens` Array pointing to the last
    #            Token of a class definition.
    def class_indexes
      @class_indexes ||= Proc.new do
        result = []
        tokens.each_with_index do |token, i|
          if token.type == :CLASS
            brace_depth = 0
            paren_depth = 0
            in_params = false
            tokens[i+1..-1].each_with_index do |class_token, j|
              if class_token.type == :LPAREN
                in_params = true if paren_depth == 1
                paren_depth += 1
              elsif class_token.type == :RPAREN
                in_params = false if paren_depth == 0
                paren_depth -= 1
              elsif class_token.type == :LBRACE
                brace_depth += 1
              elsif class_token.type == :RBRACE
                brace_depth -= 1
                if brace_depth == 0 && ! in_params
                  if token.next_code_token.type != :LBRACE
                    result << {:start => i, :end => i + j + 1}
                  end
                  break
                end
              end
            end
          end
        end
        result
      end.call
    end

    # Internal: Calculate the positions of all defined type definitions within
    # the `tokens` Array.
    #
    # Returns an Array of Hashes, each containing:
    #   :start - An Integer position in the `tokens` Array pointing to the
    #            first Token of a defined type definition.
    #   :end   - An Integer position in the `tokens` Array pointing to the last
    #            Token of a defined type definition.
    def defined_type_indexes
      @defined_type_indexes ||= Proc.new do
        result = []
        tokens.each_with_index do |token, i|
          if token.type == :DEFINE
            brace_depth = 0
            paren_depth = 0
            in_params = false
            tokens[i+1..-1].each_with_index do |define_token, j|
              if define_token.type == :LPAREN
                in_params = true if paren_depth == 0
                paren_depth += 1
              elsif define_token.type == :RPAREN
                in_params = false if paren_depth == 1
                paren_depth -= 1
              elsif define_token.type == :LBRACE
                brace_depth += 1
              elsif define_token.type == :RBRACE
                brace_depth -= 1
                if brace_depth == 0 && !in_params
                  result << {:start => i, :end => i + j + 1}
                  break
                end
              end
            end
          end
        end
        result
      end.call
    end

    # Internal: Retrieves a list of token types that are considered to be
    # formatting tokens (whitespace, newlines, etc).
    #
    # Returns an Array of Symbols.
    def formatting_tokens
      @formatting_tokens ||= PuppetLint::Lexer::FORMATTING_TOKENS
    end
  end
end
