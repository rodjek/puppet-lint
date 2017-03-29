# Public: Test the manifest tokens for any right-to-left (<-) chaining
# operators and record a warning for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#chaining-arrow-syntax
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

# Public: Test the manifest tokens for chaining arrow that is
# on the line of the left operand when the right operand is on another line.
#
# https://docs.puppet.com/guides/style_guide.html#chaining-arrow-syntax
PuppetLint.new_check(:arrow_on_right_operand_line) do
  def check
    tokens.select { |r| Set[:IN_EDGE, :IN_EDGE_SUB].include?(r.type) }.each do |token|
      if token.next_code_token.line != token.line
        notify :warning, {
          :message =>  'arrow should be on the right operand\'s line',
          :line    => token.line,
          :column  => token.column,
          :token   => token,
        }
      end
    end
  end

  def fix(problem)
    token = problem[:token]
    tokens.delete(token)

    # remove any excessive whitespace on the line
    temp_token = token.prev_code_token
    while (temp_token = temp_token.next_token)
      tokens.delete(temp_token) if whitespace?(temp_token)
      break if temp_token.type == :NEWLINE
    end

    temp_token.next_token = token
    token.prev_token = temp_token
    index = tokens.index(token.next_code_token)
    tokens.insert(index, token)

    whitespace_token = PuppetLint::Lexer::Token.new(:WHITESPACE, ' ', temp_token.line + 1, 3)
    whitespace_token.prev_token = token
    token.next_token = whitespace_token
    whitespace_token.next_token = tokens[index + 1]
    tokens[index + 1].prev_token = whitespace_token
    tokens.insert(index + 1, whitespace_token)
  end

  def whitespace?(token)
    Set[:INDENT, :WHITESPACE].include?(token.type)
  end
end

# Public: Test the manifest tokens for any classes or defined types that are
# not in an appropriately named file for the autoloader to detect and record
# an error of each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#separate-files
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
#
# No style guide reference
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
#
# No style guide reference
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
#
# https://docs.puppet.com/guides/style_guide.html#display-order-of-parameters
PuppetLint.new_check(:parameter_order) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      unless class_idx[:param_tokens].nil?
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
          next if (! hash_or_array_stack.empty?)
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
#
# https://docs.puppet.com/guides/style_guide.html#class-inheritance
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
#
# https://docs.puppet.com/guides/style_guide.html#nested-classes-or-defined-types
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

# Public: Find and warn about module names with illegal uppercase characters.
#
# https://docs.puppet.com/puppet/latest/reference/modules_fundamentals.html#allowed-module-names
# Provides a fix. [puppet-lint #554]
PuppetLint.new_check(:names_containing_uppercase) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      if class_idx[:name_token].value =~ /[A-Z]/
        if class_idx[:type] == :CLASS
          obj_type = 'class'
        else
          obj_type = 'defined type'
        end

        notify :error, {
          :message => "#{obj_type} '#{class_idx[:name_token].value}' contains illegal uppercase",
          :line    => class_idx[:name_token].line,
          :column  => class_idx[:name_token].column,
          :token   => class_idx[:name_token],
        }
      end
    end
  end

  def fix(problem)
    problem[:token].value.downcase!
  end
end

# Public: Test that no code is outside of a class or define scope.
#
# No style guide reference
PuppetLint.new_check(:code_on_top_scope) do
  def check
    class_scope = (class_indexes + defined_type_indexes).map { |e| tokens[e[:start]..e[:end]] }.flatten
    top_scope   = tokens - class_scope

    top_scope.each do |token|
      unless formatting_tokens.include? token.type
        notify :warning, {
          :message => "code outside of class or define block - #{token.value}",
          :line    => token.line,
          :column  => token.column
        }
      end
    end
  end
end
PuppetLint.configuration.send("disable_code_on_top_scope")

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

