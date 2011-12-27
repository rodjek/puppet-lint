class PuppetLint::Plugins::CheckClasses < PuppetLint::CheckPlugin
  def test(path, data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    tokens = lexer.fullscan

    tokens.select { |r| r.first == :OUT_EDGE }.each do |token|
      warn "right-to-left (<-) relationship on line #{token.last[:line]}"
    end

    class_indexes = []
    defined_type_indexes = []
    tokens.each_index do |token_idx|
      if [:DEFINE, :CLASS].include? tokens[token_idx].first
        header_end_idx = tokens[token_idx..-1].index { |r| r.first == :LBRACE }
        lparen_idx = tokens[token_idx..(header_end_idx + token_idx)].index { |r| r.first == :LPAREN }
        rparen_idx = tokens[token_idx..(header_end_idx + token_idx)].rindex { |r| r.first == :RPAREN }

        unless path == ""
          title_token = tokens[token_idx+1]
          if [:CLASSNAME, :NAME].include? title_token.first
            split_title = title_token.last[:value].split('::')
            if split_title.length > 1
              expected_path = "#{split_title.first}/manifests/#{split_title[1..-1].join('/')}.pp"
            else
              expected_path = "#{title_token.last[:value]}/manifests/init.pp"
            end

            unless path.end_with? expected_path
              error "#{title_token.last[:value]} not in autoload module layout on line #{title_token.last[:line]}"
            end
          end
        end

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
                      warn "optional parameter listed before required parameter on line #{this_token.last[:line]}"
                    end
                  end
                end
              end
            end
          end
        end
      end

      if [:CLASS, :DEFINE].include? tokens[token_idx].first
        if tokens[token_idx].first == :CLASS
          if tokens[token_idx+2].first == :INHERITS
            class_name = tokens[token_idx+1].last[:value]
            inherited_class = tokens[token_idx+3].last[:value]

            unless class_name =~ /^#{inherited_class}::/
              warn "class inherits across namespaces on line #{tokens[token_idx].last[:line]}"
            end
          end
        end

        lbrace_count = 0
        tokens[token_idx+1..-1].each_index do |class_token_idx|
          idx = class_token_idx + token_idx
          if tokens[idx].first == :LBRACE
            lbrace_count += 1
          elsif tokens[idx].first == :RBRACE
            lbrace_count -= 1
            if lbrace_count == 0
              class_indexes << {:start => token_idx, :end => idx} if tokens[token_idx].first == :CLASS
              defined_type_indexes << {:start => token_idx, :end => idx} if tokens[token_idx].first == :DEFINE
              break
            end
          end
        end
      end
    end

    class_indexes.each do |class_idx|
      class_tokens = tokens[class_idx[:start]..class_idx[:end]]
      class_tokens[1..-1].each_index do |token_idx|
        token = class_tokens[1..-1][token_idx]
        next_token = class_tokens[1..-1][token_idx + 1]

        if token.first == :CLASS
          if next_token.first != :LBRACE
            warn "class defined inside a class on line #{token.last[:line]}"
          end
        end

        if token.first == :DEFINE
          warn "define defined inside a class on line #{token.last[:line]}"
        end
      end
    end

    (class_indexes + defined_type_indexes).each do |idx|
      object_tokens = tokens[idx[:start]..idx[:end]]
      variables_in_scope = ['name', 'title', 'module_name']
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
              warn "top-scope variable being used without an explicit namespace on line #{token.last[:line]}"
            end
          end
        end
      end
    end
  end
end
