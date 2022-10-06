require 'set'
require 'strscan'

# Public: Check the manifest tokens for any variables in a string that have
# not been enclosed by braces ({}) and record a warning for each instance
# found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#quoting
PuppetLint.new_check(:variables_not_enclosed) do
  STRING_TOKEN_TYPES = Set[
    :DQMID,
    :DQPOST,
    :HEREDOC_MID,
    :HEREDOC_POST,
  ]

  def check
    invalid_tokens = tokens.select do |token|
      token.type == :UNENC_VARIABLE
    end

    invalid_tokens.each do |token|
      notify(
        :warning,
        message: 'variable not enclosed in {}',
        line: token.line,
        column: token.column,
        token: token,
        description: 'Check the manifest tokens for any variables in a string that have not been enclosed by braces ({}) and record a warning for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#quoting',
      )
    end
  end

  def hash_or_array_ref?(token)
    token.next_token &&
      STRING_TOKEN_TYPES.include?(token.next_token.type) &&
      token.next_token.value.start_with?('[')
  end

  def extract_hash_or_array_ref(token)
    scanner = StringScanner.new(token.value)

    brack_depth = 0
    result = { ref: '' }

    until scanner.eos?
      result[:ref] += scanner.getch

      # Pass a length of 1 when slicing the last character from the string
      # to prevent Ruby 1.8 returning a Fixnum instead of a String.
      case result[:ref][-1, 1]
      when '['
        brack_depth += 1
      when ']'
        brack_depth -= 1
      end

      break if brack_depth.zero? && scanner.peek(1) != '['
    end

    result[:remainder] = scanner.rest
    result
  end

  def variable_contains_dash?(token)
    token.value.include?('-')
  end

  def handle_variable_containing_dash(var_token)
    str_token = var_token.next_token

    var_name, text = var_token.value.split('-', 2)
    var_token.value = var_name

    return if str_token.nil?
    str_token.value = "-#{text}#{str_token.value}"
  end

  def fix(problem)
    problem[:token].type = :VARIABLE

    if hash_or_array_ref?(problem[:token])
      string_token = problem[:token].next_token
      tokens_index = tokens.index(string_token)

      hash_or_array_ref = extract_hash_or_array_ref(string_token)

      ref_tokens = PuppetLint::Lexer.new.tokenise(hash_or_array_ref[:ref])
      ref_tokens.each_with_index do |token, i|
        add_token(tokens_index + i, token)
      end

      string_token.value = hash_or_array_ref[:remainder]
    end

    handle_variable_containing_dash(problem[:token]) if variable_contains_dash?(problem[:token])
  end
end
