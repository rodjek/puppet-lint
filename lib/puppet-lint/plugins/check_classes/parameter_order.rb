# Public: Test the manifest tokens for any parameterised classes or defined
# types that take parameters and record a warning if there are any optional
# parameters listed before required parameters.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#display-order-of-parameters
PuppetLint.new_check(:parameter_order) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      next if class_idx[:param_tokens].nil?

      paren_stack = []
      hash_or_array_stack = []
      class_idx[:param_tokens].each_with_index do |token, i|
        if token.type == :LPAREN
          paren_stack.push(true)
        elsif token.type == :RPAREN
          paren_stack.pop
        elsif token.type == :LBRACE || token.type == :LBRACK
          hash_or_array_stack.push(true)
        elsif token.type == :RBRACE || token.type == :RBRACK
          hash_or_array_stack.pop
        end

        next unless hash_or_array_stack.empty? && paren_stack.empty?
        next unless parameter?(token)
        next unless required_parameter?(token)

        prev_tokens = class_idx[:param_tokens][0..i]
        next if prev_tokens.rindex { |r| r.type == :EQUALS }.nil?

        msg = 'optional parameter listed before required parameter'
        notify(
          :warning,
          message: msg,
          line: token.line,
          column: token.column,
          description: 'Test the manifest tokens for any parameterised classes or defined types that take '\
            'parameters and record a warning if there are any optional parameters listed before required parameters.',
          help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#display-order-of-parameters',
        )
      end
    end
  end

  def parameter?(token)
    return false unless token.type == :VARIABLE
    return false unless token.prev_code_token

    [
      :LPAREN, # First parameter, no type specification
      :COMMA,  # Subsequent parameter, no type specification
      :TYPE,   # Parameter with simple type specification
      :RBRACK, # Parameter with complex type specification
    ].include?(token.prev_code_token.type)
  end

  def required_parameter?(token)
    data_type = token.prev_token_of(:TYPE, skip_blocks: true)
    return false if data_type && data_type.value == 'Optional'

    if token.next_code_token.nil? || [:COMMA, :RPAREN].include?(token.next_code_token.type)
      return !(token.prev_code_token && token.prev_code_token.type == :EQUALS)
    end

    false
  end
end
