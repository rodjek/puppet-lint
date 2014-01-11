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
        class_tokens = class_idx[:tokens]
        title_token = class_tokens.select { |r| r.type == :NAME }.first
        split_title = title_token.value.split('::')
        mod = split_title.first
        if split_title.length > 1
          expected_path = "/#{mod}/manifests/#{split_title[1..-1].join('/')}.pp"
        else
          expected_path = "/#{title_token.value}/manifests/init.pp"
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
# have a dash in their name and record a warning for each instance found.
PuppetLint.new_check(:names_containing_dash) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      class_tokens = class_idx[:tokens]
      title_token = class_tokens.select { |r| r.type == :NAME }.first

      if title_token.value.include? '-'
        if class_tokens.first.type == :CLASS
          obj_type = 'class'
        else
          obj_type = 'defined type'
        end

        notify :warning, {
          :message => "#{obj_type} name containing a dash",
          :line    => title_token.line,
          :column  => title_token.column,
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
      class_tokens = class_idx[:tokens]
      inherits_token = class_tokens.select { |r| r.type == :INHERITS }.first

      unless inherits_token.nil?
        inherited_class_token = inherits_token.next_code_token
        if inherited_class_token.value.end_with? '::params'
          notify :warning, {
            :message => 'class inheriting from params class',
            :line    => inherited_class_token.line,
            :column  => inherited_class_token.column,
          }
        end
      end
    end
  end
end

# Public: Test the manifest tokens for any parameterised classes or defined
# types that take parameters and record a warning if there are any optional
# parameters listed before required parameters.
PuppetLint.new_check(:parameter_order) do
  def check
    defined_type_indexes.each do |class_idx|
      unless class_idx[:param_tokens].nil?
        param_tokens = class_idx[:param_tokens].reject { |r|
          formatting_tokens.include? r.type
        }

        paren_stack = []
        param_tokens.each_index do |param_tokens_idx|
          this_token = param_tokens[param_tokens_idx]
          next_token = param_tokens[param_tokens_idx+1]
          prev_token = param_tokens[param_tokens_idx-1]

          if this_token.type == :LPAREN
            paren_stack.push(true)
          elsif this_token.type == :RPAREN
            paren_stack.pop
          end
          next unless paren_stack.empty?

          if this_token.type == :VARIABLE
            if next_token.nil? || next_token.type == :COMMA
              prev_tokens = param_tokens[0..param_tokens_idx]
              unless prev_tokens.rindex { |r| r.type == :EQUALS }.nil?
                unless prev_token.nil? or prev_token.type == :EQUALS
                  msg = 'optional parameter listed before required parameter'
                  notify :warning, {
                    :message => msg,
                    :line    => this_token.line,
                    :column  => this_token.column,
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
      class_token = class_idx[:tokens].first
      class_name_token = class_token.next_code_token
      inherits_token = class_idx[:tokens].select { |r| r.type == :INHERITS }.first
      next if inherits_token.nil?

      inherited_class_token = inherits_token.next_code_token
      inherited_module_name = inherited_class_token.value.split('::').reject { |r| r.empty? }.first
      class_module_name = class_name_token.value.split('::').reject { |r| r.empty? }.first

      unless class_module_name == inherited_module_name
        notify :warning, {
          :message => "class inherits across module namespaces",
          :line    => inherited_class_token.line,
          :column  => inherited_class_token.column,
        }
      end
    end
  end
end

# Public: Test the manifest tokens for any classes or defined types that are
# defined inside another class.
PuppetLint.new_check(:nested_classes_or_defines) do
  def check
    class_indexes.each do |class_idx|
      # Skip the first token so that we don't pick up the first :CLASS
      class_tokens = class_idx[:tokens][1..-1]

      class_tokens.each do |token|
        if token.type == :CLASS
          if token.next_code_token.type != :LBRACE
            notify :warning, {
              :message => "class defined inside a class",
              :line    => token.line,
              :column  => token.column,
            }
          end
        end

        if token.type == :DEFINE
          notify :warning, {
            :message => "defined type defined inside a class",
            :line    => token.line,
            :column  => token.column,
          }
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
  def check
    variables_in_scope = [
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
    ]

    (class_indexes + defined_type_indexes).each do |idx|
      referenced_variables = []
      object_tokens = idx[:tokens]

      unless idx[:param_tokens].nil?
        param_tokens = idx[:param_tokens]
        param_tokens.each do |token|
          if token.type == :VARIABLE
            if Set[:COMMA, :EQUALS, :RPAREN].include? token.next_code_token.type
              variables_in_scope << token.value
            end
          end
        end
      end

      object_tokens.each do |token|
        if token.type == :VARIABLE
          if token.next_code_token.type == :EQUALS
            variables_in_scope << token.value
          else
            referenced_variables << token
          end
        end
      end

      msg = "top-scope variable being used without an explicit namespace"
      referenced_variables.each do |token|
        unless token.value.include? '::'
          unless variables_in_scope.include? token.value
            unless token.value =~ /\d+/
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
