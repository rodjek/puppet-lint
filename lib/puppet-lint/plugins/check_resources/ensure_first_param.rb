# Public: Check the tokens of each resource instance for an ensure parameter
# and if found, check that it is the first parameter listed.  If it is not
# the first parameter, record a warning.
#
# https://docs.puppet.com/guides/style_guide.html#attribute-ordering
PuppetLint.new_check(:ensure_first_param) do
  def check
    resource_indexes.each do |resource|
      next if [:CLASS].include? resource[:type].type
      ensure_attr_index = resource[:param_tokens].index { |param_token|
        param_token.value == 'ensure'
      }

      unless ensure_attr_index.nil?
        if ensure_attr_index > 0
          ensure_token = resource[:param_tokens][ensure_attr_index]
          notify :warning, {
            :message  => "ensure found on line but it's not the first attribute",
            :line     => ensure_token.line,
            :column   => ensure_token.column,
            :resource => resource,
          }
        end
      end
    end
  end

  def fix(problem)
    first_param_name_token = tokens[problem[:resource][:start]].next_token_of(:NAME)
    first_param_comma_token = first_param_name_token.next_token_of(:COMMA)
    ensure_param_name_token = first_param_comma_token.next_token_of(:NAME, :value => 'ensure')
    ensure_param_comma_token = ensure_param_name_token.next_token_of([:COMMA, :SEMIC])

    if first_param_name_token.nil? or first_param_comma_token.nil? or ensure_param_name_token.nil? or ensure_param_comma_token.nil?
      raise PuppetLint::NoFix
    end

    first_param_name_idx = tokens.index(first_param_name_token)
    first_param_comma_idx = tokens.index(first_param_comma_token)
    ensure_param_name_idx = tokens.index(ensure_param_name_token)
    ensure_param_comma_idx = tokens.index(ensure_param_comma_token)

    # Flip params
    prev_token = first_param_name_token.prev_token
    first_param_name_token.prev_token = ensure_param_name_token.prev_token
    ensure_param_name_token.prev_token = prev_token

    prev_code_token = first_param_name_token.prev_code_token
    first_param_name_token.prev_code_token = ensure_param_name_token.prev_code_token
    ensure_param_name_token.prev_code_token = prev_code_token

    next_token = first_param_comma_token.next_token
    first_param_comma_token = ensure_param_comma_token.next_token
    ensure_param_comma_token.next_token = next_token

    next_code_token = first_param_comma_token.next_code_token
    first_param_comma_code_token = ensure_param_comma_token.next_code_token
    ensure_param_comma_token.next_code_token = next_code_token

    # Update index
    ensure_tmp = tokens.slice!(ensure_param_name_idx..ensure_param_comma_idx-1)
    first_tmp = tokens.slice!(first_param_name_idx..first_param_comma_idx-1)
    ensure_tmp.reverse_each do |item|
      tokens.insert(first_param_name_idx, item)
    end
    first_tmp.reverse_each do |item|
      tokens.insert(ensure_param_name_idx + ensure_tmp.length - first_tmp.length, item)
    end
  end
end
