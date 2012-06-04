class PuppetLint::Plugins::CheckStrings < PuppetLint::CheckPlugin
  class ::Puppet::Parser::Lexer
    class TokenList
      def del_token(token)
        @tokens.delete(token)
      end
    end

    TOKENS.add_tokens("<single quotes string>" => :SSTRING)
    TOKENS.del_token(:SQUOTE)

    if Puppet::PUPPETVERSION =~ /^0\.2/
      TOKENS.add_token :SQUOTE, "'" do |lexer, value|
        value = lexer.slurpstring(value)
        [TOKENS[:SSTRING], value]
      end
    else
      TOKENS.add_token :SQUOTE, "'" do |lexer, value|
        [ TOKENS[:SSTRING], lexer.slurpstring(value,["'"],:ignore_invalid_escapes).first ]
      end
    end
  end

  check 'double_quoted_strings' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :STRING
        unless token.last[:value].include? "\t" or token.last[:value].include? "\n"
          notify :warning, :message =>  "double quoted string containing no variables", :linenumber => token.last[:line]
        end
      elsif token.first == :DQTEXT
        unless token.last[:value].include? "\\t" or token.last[:value].include? "\\n" or token.last[:value] =~ /[^\\]?\$\{?/
          notify :warning, :message =>  "double quoted string containing no variables", :linenumber => token.last[:line]
        end
      end
    end
  end

  check 'only_variable_string' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :DQPRE and token.last[:value] == ""
        if tokens[token_idx + 1].first == :VARIABLE
          if tokens[token_idx + 2].first == :DQPOST and tokens[token_idx + 2].last[:value] == ""
            notify :warning, :message =>  "string containing only a variable", :linenumber => tokens[token_idx + 1].last[:line]
          end
        end
      end
      if token.first == :DQTEXT and token.last[:value] =~ /\A\$\{.+\}\Z/
        notify :warning, :message =>  "string containing only a variable", :linenumber => token.last[:line]
      end
    end
  end

  check 'variables_not_enclosed' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :DQPRE
        end_of_string_offset = tokens[token_idx..-1].index { |r| r.first == :DQPOST }
        end_of_string_idx = token_idx + end_of_string_offset
        tokens[token_idx..end_of_string_idx].each do |t|
          if t.first == :VARIABLE
            line = data.split("\n")[t.last[:line] - 1]
            if line.is_a? String and line.include? "$#{t.last[:value]}"
              notify :warning, :message =>  "variable not enclosed in {}", :linenumber => t.last[:line]
            end
          end
        end
      elsif token.first == :DQTEXT and token.last[:value] =~ /\$\w+/
        notify :warning, :message =>  "variable not enclosed in {}", :linenumber => token.last[:line]
      end
    end
  end

  check 'single_quote_string_with_variables' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if token.first == :SSTRING
        contents = token.last[:value]
        line_no = token.last[:line]

        if contents.include? '${'
          notify :error, :message =>  "single quoted string containing a variable found", :linenumber => token.last[:line]
        end
      end
    end
  end

  check 'quoted_booleans' do
    tokens.each_index do |token_idx|
      token = tokens[token_idx]

      if [:STRING, :SSTRING].include? token.first
        contents = token.last[:value]
        line_no = token.last[:line]

        if ['true', 'false'].include? contents
          notify :warning, :message =>  "quoted boolean value found", :linenumber => token.last[:line]
        end
      end
    end
  end
end
