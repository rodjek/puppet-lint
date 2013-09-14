require 'puppet-lint/checkplugin'

class PuppetLint::Checks
  # Public: Get an Array of problem Hashes.
  attr_reader :problems

  # Public: Get an Array of PuppetLint::Lexer::Token objects.
  attr_reader :tokens

  # Public: Initialise a new PuppetLint::Checks object and prepare the check
  # methods.
  def initialize
    @problems = []
    @default_info = {:check => 'unknown', :linenumber => 0, :column => 0}

    PuppetLint.configuration.checks.each do |check|
      method = PuppetLint.configuration.check_method[check]
      self.class.send(:define_method, "lint_check_#{check}", &method)
    end

    PuppetLint.configuration.helpers.each do |helper|
      method = PuppetLint.configuration.helper_method[helper]
      self.class.send(:define_method, helper, &method)
    end
  end

  # Public: Add a message to the problems array.
  #
  # kind    - The kind of problem as a Symbol (:warning, :error).
  # problem - A Hash containing the attributes of the problem.
  #   :message    - The String message describing the problem.
  #   :linenumber - The Integer line number of the location of the problem.
  #   :check      - The String name of the check that the problem came from.
  #   :column     - The Integer column number of the location of the problem.
  #
  # Returns nothing.
  def notify(kind, problem)
    problem[:kind] = kind
    problem.merge!(@default_info) {|key, v1, v2| v1 }
    @problems << problem
  end

  # Internal: Tokenise the manifest code and prepare it for checking.
  #
  # fileinfo - A Hash containing the following:
  #   :fullpath - The expanded path to the file as a String.
  #   :filename - The name of the file as a String.
  #   :path     - The original path to the file as passed to puppet-lint as
  #               a String.
  # data     - The String manifest code to be checked.
  #
  # Returns nothing.
  def load_data(fileinfo, data)
    lexer = PuppetLint::Lexer.new
    begin
      @tokens = lexer.tokenise(data)
    rescue PuppetLint::LexerError => e
      notify :error, {
        :check      => :syntax,
        :message    => 'Syntax error (try running `puppet parser validate <file>`)',
        :linenumber => e.line_no,
        :column     => e.column,
      }
      @tokens = []
    end
    @fileinfo = fileinfo
    @data = data
  end

  # Internal: Run the lint checks over the manifest code.
  #
  # fileinfo - A Hash containing the following:
  #   :fullpath - The expanded path to the file as a String.
  #   :filename - The name of the file as a String.
  #   :path     - The original path to the file as passed to puppet-lint as
  #               a String.
  # data     - The String manifest code to be checked.
  #
  # Returns an Array of problem Hashes.
  def run(fileinfo, data)
    load_data(fileinfo, data)

    enabled_checks.each do |check|
      @default_info[:check] = check
      self.send("lint_check_#{check}")
    end

    @problems
  end

  # Internal: Get a list of checks that have not been disabled.
  #
  # Returns an Array of String check names.
  def enabled_checks
    @enabled_checks ||= Proc.new do
      self.public_methods.select { |method|
        method.to_s.start_with? 'lint_check_'
      }.map { |method|
        method.to_s[11..-1]
      }.select { |name|
        PuppetLint.configuration.send("#{name}_enabled?")
      }
    end.call
  end

  # Public: Get the full expanded path to the file being checked.
  #
  # Returns a String path.
  def fullpath
    @fileinfo[:fullpath]
  end

  # Public: Retrieve a list of tokens that represent resource titles.
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

  # Public: Calculate the positions of all resource declarations within the
  # tokenised manifest.  These positions only point to the content of the
  # resource declaration, they do not include resource types or
  # titles/namevars.
  #
  # Returns an Array of Hashes, each containing:
  #   :start - An Integer position in the `tokens` Array pointing to the first
  #            Token of a resource declaration parameters (type :NAME).
  #   :end   - An Integer position in the `tokens` Array pointing to the last
  #            Token of a resource declaration parameters (type :RBRACE).
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

  # Public: Calculate the positions of all class definitions within the
  # tokenised manifest.
  #
  # Returns an Array of Hashes, each containing:
  #   :start - An Integer position in the `tokens` Array pointing to the first
  #            token of a class (type :CLASS).
  #   :end   - An Integer position in the `tokens` Array pointing to the last
  #            token of a class (type :RBRACE).
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

  # Public: Calculate the positions of all defined type definitions within
  # the tokenised manifest.
  #
  # Returns an Array of Hashes, each containing:
  #   :start - An Integer position in the `tokens` Array pointing to the first
  #            token of a defined type (type :DEFINE).
  #   :end   - An Integer position in the `tokens` Array pointing to the last
  #            token of a defined type (type :RBRACE).
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

  # Public: Retrieves a list of token types that are considered to be
  # formatting tokens (ie whitespace, newlines, etc).
  #
  # Returns an Array of Symbols.
  def formatting_tokens
    @formatting_tokens ||= PuppetLint::Lexer::FORMATTING_TOKENS
  end

  # Public: Access the lines of the manifest that is being checked.
  #
  # Returns an Array of Strings.
  def manifest_lines
    @manifest_lines ||= @data.split("\n")
  end

  def manifest
    tokens.map { |t| t.to_manifest }.join('')
  end
end
