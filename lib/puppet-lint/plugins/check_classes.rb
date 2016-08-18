# Public: Test the manifest tokens for any right-to-left (<-) chaining
# operators and record a warning for each instance found.
PuppetLint.new_check(:right_to_left_relationship) do
  def check
    tokens.select { |r| r.type == :OUT_EDGE }.each do |token|
      notify :warning, {
        :message =>  'right-to-left (<-) relationship',
        :line    => token.line,
        :column  => token.column,
      }
    end
  end
end

# Public: Test the manifest tokens for any classes or defined types that are
# not in an appropriately named file for the autoloader to detect and record
# an error of each instance found.
PuppetLint.new_check(:autoloader_layout) do
  def check
    unless fullpath.nil? || fullpath == ''
      (class_indexes + defined_type_indexes).each do |class_idx|
        title_token = class_idx[:name_token]
        split_title = title_token.value.split('::')
        mod = split_title.first
        if split_title.length > 1
          expected_path = "/#{mod}/manifests/#{split_title[1..-1].join('/')}.pp"
        else
          expected_path = "/#{title_token.value}/manifests/init.pp"
        end

        if PuppetLint.configuration.relative
          expected_path = expected_path.gsub(/^\//,'').split('/')[1..-1].join('/')
        end

        unless fullpath.end_with? expected_path
          notify :error, {
            :message => "#{title_token.value} not in autoload module layout",
            :line    => title_token.line,
            :column  => title_token.column,
          }
        end
      end
    end
  end
end

# Public: Check the manifest tokens for any classes or defined types that
# have a dash in their name and record an error for each instance found.
PuppetLint.new_check(:names_containing_dash) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      if class_idx[:name_token].value.include? '-'
        if class_idx[:type] == :CLASS
          obj_type = 'class'
        else
          obj_type = 'defined type'
        end

        notify :error, {
          :message => "#{obj_type} name containing a dash",
          :line    => class_idx[:name_token].line,
          :column  => class_idx[:name_token].column,
        }
      end
    end
  end
end

# Public: Check the manifest tokens for any classes that inherit a params
# subclass and record a warning for each instance found.
PuppetLint.new_check(:class_inherits_from_params_class) do
  def check
    class_indexes.each do |class_idx|
      unless class_idx[:inherited_token].nil?
        if class_idx[:inherited_token].value.end_with? '::params'
          notify :warning, {
            :message => 'class inheriting from params class',
            :line    => class_idx[:inherited_token].line,
            :column  => class_idx[:inherited_token].column,
          }
        end
      end
    end
  end
end
PuppetLint.configuration.send('disable_class_inherits_from_params_class')

# Public: Test the manifest tokens for any parameterised classes or defined
# types that take parameters and record a warning if there are any optional
# parameters listed before required parameters.
PuppetLint.new_check(:parameter_order) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      unless class_idx[:param_tokens].nil?
        paren_stack = []
        class_idx[:param_tokens].each_with_index do |token, i|
          if token.type == :LPAREN
            paren_stack.push(true)
          elsif token.type == :RPAREN
            paren_stack.pop
          end
          next unless paren_stack.empty?

          if token.type == :VARIABLE
            if token.next_code_token.nil? || [:COMMA, :RPAREN].include?(token.next_code_token.type)
              prev_tokens = class_idx[:param_tokens][0..i]
              unless prev_tokens.rindex { |r| r.type == :EQUALS }.nil?
                unless token.prev_code_token.nil? or token.prev_code_token.type == :EQUALS
                  msg = 'optional parameter listed before required parameter'
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
end

# Public: Test the manifest tokens for any classes that inherit across
# namespaces and record a warning for each instance found.
PuppetLint.new_check(:inherits_across_namespaces) do
  def check
    class_indexes.each do |class_idx|
      unless class_idx[:inherited_token].nil?
        inherited_module_name = class_idx[:inherited_token].value.split('::').reject { |r| r.empty? }.first
        class_module_name = class_idx[:name_token].value.split('::').reject { |r| r.empty? }.first

        unless class_module_name == inherited_module_name
          notify :warning, {
            :message => "class inherits across module namespaces",
            :line    => class_idx[:inherited_token].line,
            :column  => class_idx[:inherited_token].column,
          }
        end
      end
    end
  end
end

# Public: Test the manifest tokens for any classes or defined types that are
# defined inside another class.
PuppetLint.new_check(:nested_classes_or_defines) do
  TOKENS = Set[:CLASS, :DEFINE]

  def check
    class_indexes.each do |class_idx|
      # Skip the first token so that we don't pick up the first :CLASS
      class_tokens = class_idx[:tokens][1..-1]

      class_tokens.each do |token|
        if TOKENS.include?(token.type)
          if token.next_code_token.type != :LBRACE
            type = token.type == :CLASS ? 'class' : 'defined type'

            notify :warning, {
              :message => "#{type} defined inside a class",
              :line    => token.line,
              :column  => token.column,
            }
          end
        end
      end
    end
  end
end

# Public: Test the manifest tokens for any variables that are referenced in
# the manifest.  If the variables are not fully qualified or one of the
# variables automatically created in the scope, check that they have been
# defined in the local scope and record a warning for each variable that has
# not.
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
      temp_scope_vars = []

      object_tokens.each do |token|
        if token.type == :VARIABLE
          if in_pipe
            temp_scope_vars << token.value
          else
            if token.next_code_token.type == :EQUALS
              variables_in_scope << token.value
            else
              referenced_variables << token
            end
          end
        elsif token.type == :PIPE
          in_pipe = !in_pipe

          if in_pipe
            temp_scope_vars = []
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

            future_parser_scopes.merge!(Hash[(token.line..end_token.line).to_a.map { |i| [i, temp_scope_vars] }])
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
