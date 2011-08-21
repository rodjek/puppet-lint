# Resources
# http://docs.puppetlabs.com/guides/style_guide.html#resources

class PuppetLint::Plugins::CheckResources < PuppetLint::CheckPlugin
  def test(data)
    lexer = Puppet::Parser::Lexer.new
    lexer.string = data
    tokens = lexer.fullscan

    title_tokens = []
    resource_indexes = []
    tokens.each_index do |token_idx|
      if tokens[token_idx].first == :COLON
        # gather a list of tokens that are resource titles
        if tokens[token_idx-1].first == :RBRACK
          title_array_tokens = tokens[tokens.rindex { |r| r.first == :LBRACK }+1..token_idx-2]
          title_tokens += title_array_tokens.select { |token| [:STRING, :NAME].include? token.first }
        else
          title_tokens << tokens[token_idx-1]
        end

        # gather a list of start and end indexes for resource attribute blocks
        if tokens[token_idx+1].first != :LBRACE
          resource_indexes << {:start => token_idx+1, :end => tokens[token_idx+1..-1].index { |r| [:SEMIC, :RBRACE].include? r.first }+token_idx}
        end
      end
    end

    title_tokens.each do |token|
      if token.first == :NAME
        warn "unquoted resource title on line #{token.last[:line]}"
      end
    end

    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      ensure_attr_index = resource_tokens.index { |token| token.first == :NAME and token.last[:value] == 'ensure' }
      unless ensure_attr_index.nil?
        if ensure_attr_index > 1
          ensure_attr_line_no = resource_tokens[ensure_attr_index].last[:line]
          warn "ensure found on line #{ensure_attr_line_no} but it's not the first attribute"
        end
      end

      resource_tokens.each_index do |resource_token_idx|
        if resource_tokens[resource_token_idx].first == :FARROW
          if resource_tokens[resource_token_idx + 1].first == :VARIABLE
            if resource_tokens[resource_token_idx + 2].first == :QMARK
              warn "selector inside resource block on line #{resource_tokens[resource_token_idx].last[:line]}"
            end
          end
        end
      end

      resource_type_token = tokens[tokens[0..resource[:start]].rindex { |r| r.first == :LBRACE } - 1]
      if resource_type_token.last[:value] == "file"
        resource_tokens.each_index do |resource_token_idx|
          attr_token = resource_tokens[resource_token_idx]
          if attr_token.first == :NAME and attr_token.last[:value] == 'mode'
            value_token = resource_tokens[resource_token_idx + 2]
            if value_token.first == :NAME
              warn "unquoted file mode on line #{value_token.last[:line]}"
            end
            if value_token.last[:value] !~ /\d{4}/
              warn "mode should be represented as a 4 digit octal value on line #{value_token.last[:line]}"
            end
          elsif attr_token.first == :NAME and attr_token.last[:value] == 'ensure'
            value_token = resource_tokens[resource_token_idx + 2]
            if value_token.last[:value].start_with? '/'
              warn "symlink target specified in ensure attr on line #{value_token.last[:line]}"
            end
          end
        end
      end
    end
  end
end
