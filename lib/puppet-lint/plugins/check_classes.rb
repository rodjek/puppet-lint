class PuppetLint::Plugins::CheckClasses < PuppetLint::CheckPlugin
  if Puppet::PUPPETVERSION !~ /^0\.2/
    check 'right_to_left_relationship' do
      tokens.select { |r| r.first == :OUT_EDGE }.each do |token|
        notify :warning, :message =>  "right-to-left (<-) relationship", :linenumber => token.last[:line]
      end
    end
  end

  check 'autoloader_layout' do
    unless fullpath == ""
      (class_indexes + defined_type_indexes).each do |class_idx|
        title_token = tokens[class_idx[:start]+1]
        split_title = title_token.last[:value].split('::')
        if split_title.length > 1
          expected_path = "#{split_title.first}/manifests/#{split_title[1..-1].join('/')}.pp"
        else
          expected_path = "#{title_token.last[:value]}/manifests/init.pp"
        end

        unless fullpath.end_with? expected_path
          notify :error, :message =>  "#{title_token.last[:value]} not in autoload module layout", :linenumber => title_token.last[:line]
        end
      end
    end
  end

  check 'parameter_order' do
    (class_indexes + defined_type_indexes).each do |class_idx|
      token_idx = class_idx[:start]
      header_end_idx = tokens[token_idx..-1].index { |r| r.first == :LBRACE }
      lparen_idx = tokens[token_idx..(header_end_idx + token_idx)].index { |r| r.first == :LPAREN }
      rparen_idx = tokens[token_idx..(header_end_idx + token_idx)].rindex { |r| r.first == :RPAREN }

      unless lparen_idx.nil? or rparen_idx.nil?
        param_tokens = tokens[lparen_idx..rparen_idx]
        param_tokens.each_index do |param_tokens_idx|
          this_token = param_tokens[param_tokens_idx]
          next_token = param_tokens[param_tokens_idx+1]
          prev_token = param_tokens[param_tokens_idx-1]
          if this_token.first == :VARIABLE
            unless next_token.nil?
              if next_token.first == :COMMA or next_token.first == :RPAREN
                unless param_tokens[0..param_tokens_idx].rindex { |r| r.first == :EQUALS }.nil?
                  unless prev_token.nil? or prev_token.first == :EQUALS
                    notify :warning, :message =>  "optional parameter listed before required parameter", :linenumber => this_token.last[:line]
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  check 'inherits_across_namespaces' do
    class_indexes.each do |class_idx|
      token_idx = class_idx[:start]
      if tokens[token_idx+2].first == :INHERITS
        class_name = tokens[token_idx+1].last[:value]
        inherited_class = tokens[token_idx+3].last[:value]

        unless class_name =~ /^#{inherited_class}::/
          notify :warning, :message =>  "class inherits across namespaces", :linenumber => tokens[token_idx].last[:line]
        end
      end
    end
  end

  check 'nested_classes_or_defines' do
    class_indexes.each do |class_idx|
      class_tokens = tokens[class_idx[:start]..class_idx[:end]]
      class_tokens[1..-1].each_index do |token_idx|
        token = class_tokens[1..-1][token_idx]
        next_token = class_tokens[1..-1][token_idx + 1]

        if token.first == :CLASS
          if next_token.first != :LBRACE
            notify :warning, :message =>  "class defined inside a class", :linenumber => token.last[:line]
          end
        end

        if token.first == :DEFINE
          notify :warning, :message =>  "define defined inside a class", :linenumber => token.last[:line]
        end
      end
    end
  end

  check 'variable_scope' do
    (class_indexes + defined_type_indexes).each do |idx|
      object_tokens = tokens[idx[:start]..idx[:end]]
      variables_in_scope = ['name', 'title', 'module_name', 'environment', 'clientcert', 'clientversion', 'servername', 'serverip', 'serverversion', 'caller_module_name']
      referenced_variables = []
      header_end_idx = object_tokens.index { |r| r.first == :LBRACE }
      lparen_idx = object_tokens[0..header_end_idx].index { |r| r.first == :LPAREN }
      rparen_idx = object_tokens[0..header_end_idx].rindex { |r| r.first == :RPAREN }

      unless lparen_idx.nil? or rparen_idx.nil?
        param_tokens = object_tokens[lparen_idx..rparen_idx]
        param_tokens.each_index do |param_tokens_idx|
          this_token = param_tokens[param_tokens_idx]
          next_token = param_tokens[param_tokens_idx+1]
          if this_token.first == :VARIABLE
            if [:COMMA, :EQUALS, :RPAREN].include? next_token.first
              variables_in_scope << this_token.last[:value]
            end
          end
        end
      end

      object_tokens.each_index do |object_token_idx|
        this_token = object_tokens[object_token_idx]
        next_token = object_tokens[object_token_idx + 1]

        if this_token.first == :VARIABLE
          if next_token.first == :EQUALS
            variables_in_scope << this_token.last[:value]
          else
            referenced_variables << this_token
          end
        end
      end

      referenced_variables.each do |token|
        unless token.last[:value].include? '::'
          unless variables_in_scope.include? token.last[:value]
            unless token.last[:value] =~ /\d+/
              notify :warning, :message =>  "top-scope variable being used without an explicit namespace", :linenumber => token.last[:line]
            end
          end
        end
      end
    end
  end
end
