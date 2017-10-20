# In parameterized class and defined type declarations, parameters that are
# required should be listed before optional parameters (i.e. parameters with
# default values).
#
# @example What you have done
#   class ntp(
#     $options = 'iburst',
#     $servers,
#     $multicast = false,
#   ) {}
#
# @example What you should have done
#   class ntp(
#     $servers,
#     $multicast = false,
#     $options   = 'iburst',
#   ) { }
#
# @style_guide #display-order-of-parameters
# @enabled true
PuppetLint.new_check(:parameter_order) do
  # Test the manifest tokens for any parameterised classes or defined types
  # that take parameters and record a warning if there are any optional
  # parameters listed before required parameters.
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
        next unless required_parameter?(token)

        prev_tokens = class_idx[:param_tokens][0..i]
        next if prev_tokens.rindex { |r| r.type == :EQUALS }.nil?

        msg = 'optional parameter listed before required parameter'
        notify(
          :warning,
          :message => msg,
          :line    => token.line,
          :column  => token.column
        )
      end
    end
  end

  def required_parameter?(token)
    return false unless token.type == :VARIABLE

    data_type = token.prev_token_of(:TYPE, :skip_blocks => true)
    return false if data_type && data_type.value == 'Optional'

    if token.next_code_token.nil? || [:COMMA, :RPAREN].include?(token.next_code_token.type)
      return !(token.prev_code_token && token.prev_code_token.type == :EQUALS)
    end

    false
  end
end
