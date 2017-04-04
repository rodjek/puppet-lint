# Public: Test the manifest tokens for any variables that are referenced in
# the manifest.  If the variables are not fully qualified or one of the
# variables automatically created in the scope, check that they have been
# defined in the local scope and record a warning for each variable that has
# not.
#
# https://docs.puppet.com/guides/style_guide.html#namespacing-variables
PuppetLint.new_check(:variable_scope) do
  DEFAULT_SCOPE_VARS = Set[
    'name',
    'title',
    'module_name',
    'environment',
    'clientcert',
    'clientversion',
    'servername',
    'serverip',
    'serverversion',
    'caller_module_name',
    'alias',
    'audit',
    'before',
    'loglevel',
    'noop',
    'notify',
    'require',
    'schedule',
    'stage',
    'subscribe',
    'tag',
    'facts',
    'trusted',
    'server_facts',
  ]
  POST_VAR_TOKENS = Set[:COMMA, :EQUALS, :RPAREN]

  def check
    variables_in_scope = DEFAULT_SCOPE_VARS.clone

    (class_indexes + defined_type_indexes).each do |idx|
      referenced_variables = Set[]
      object_tokens = idx[:tokens]

      unless idx[:param_tokens].nil?
        idx[:param_tokens].each do |token|
          if token.type == :VARIABLE
            if POST_VAR_TOKENS.include? token.next_code_token.type
              variables_in_scope << token.value
            end
          end
        end
      end

      future_parser_scopes = {}
      in_pipe = false
      block_params_stack = []

      object_tokens.each do |token|
        case token.type
        when :EQUALS
          if token.prev_code_token.type == :VARIABLE
            variables_in_scope << token.prev_code_token.value
          elsif token.prev_code_token.type == :RBRACK
            temp_token = token

            brack_depth = 0
            while temp_token = temp_token.prev_code_token
              case temp_token.type
              when :VARIABLE
                variables_in_scope << temp_token.value
              when :RBRACK
                brack_depth += 1
              when :LBRACK
                brack_depth -= 1
                break if brack_depth == 0
              when :COMMA
                # ignore
              else  # unexpected
                break
              end
            end
          end
        when :VARIABLE
          if in_pipe
            block_params_stack[-1] << token.value
          else
            referenced_variables << token
          end
        when :PIPE
          in_pipe = !in_pipe

          if in_pipe
            block_params_stack << []
          else
            start_idx = tokens.find_index(token)
            end_token = nil
            brace_depth = 0

            tokens[start_idx..-1].each do |sub_token|
              case sub_token.type
              when :LBRACE
                brace_depth += 1
              when :RBRACE
                brace_depth -= 1
                if brace_depth == 0
                  end_token = sub_token
                  break
                end
              end
            end

            params = block_params_stack.pop
            (token.line..end_token.line).each do |line|
              future_parser_scopes[line] ||= []
              future_parser_scopes[line].concat(params)
            end
          end
        end
      end

      msg = "top-scope variable being used without an explicit namespace"
      referenced_variables.each do |token|
        unless future_parser_scopes[token.line].nil?
          next if future_parser_scopes[token.line].include?(token.value.gsub(/\[.+\]\Z/, ''))
        end

        unless token.value.include? '::'
          unless token.value =~ /^(facts|trusted)\[.+\]/
            unless variables_in_scope.include? token.value.gsub(/\[.+\]\Z/, '')
              unless token.value =~ /\A\d+\Z/
                notify :warning, {
                  :message => msg,
                  :line    => token.line,
                  :column  => token.column,
                }
              end
            end
          end
        end
      end
    end
  end
end
