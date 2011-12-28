# Resources
# http://docs.puppetlabs.com/guides/style_guide.html#resources

class PuppetLint::Plugins::CheckResources < PuppetLint::CheckPlugin
  check 'unquoted_resource_title' do
    title_tokens.each do |token|
      if token.first == :NAME
        warn "unquoted resource title on line #{token.last[:line]}"
      end
    end
  end

  check 'ensure_first_param' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      ensure_attr_index = resource_tokens.index { |token| token.first == :NAME and token.last[:value] == 'ensure' }
      unless ensure_attr_index.nil?
        if ensure_attr_index > 1
          ensure_attr_line_no = resource_tokens[ensure_attr_index].last[:line]
          warn "ensure found on line #{ensure_attr_line_no} but it's not the first attribute"
        end
      end
    end
  end

  check 'unquoted_file_mode' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      resource_type_token = tokens[tokens[0..resource[:start]].rindex { |r| r.first == :LBRACE } - 1]
      if resource_type_token.last[:value] == "file"
        resource_tokens.each_index do |resource_token_idx|
          attr_token = resource_tokens[resource_token_idx]
          if attr_token.first == :NAME and attr_token.last[:value] == 'mode'
            value_token = resource_tokens[resource_token_idx + 2]
            if value_token.first == :NAME
              warn "unquoted file mode on line #{value_token.last[:line]}"
            end
          end
        end
      end
    end
  end

  check '4digit_file_mode' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      resource_type_token = tokens[tokens[0..resource[:start]].rindex { |r| r.first == :LBRACE } - 1]
      if resource_type_token.last[:value] == "file"
        resource_tokens.each_index do |resource_token_idx|
          attr_token = resource_tokens[resource_token_idx]
          if attr_token.first == :NAME and attr_token.last[:value] == 'mode'
            value_token = resource_tokens[resource_token_idx + 2]
            if value_token.last[:value] !~ /\d{4}/ and value_token.first != :VARIABLE
              warn "mode should be represented as a 4 digit octal value on line #{value_token.last[:line]}"
            end
          end
        end
      end
    end
  end

  check 'ensure_not_symlink_target' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      resource_type_token = tokens[tokens[0..resource[:start]].rindex { |r| r.first == :LBRACE } - 1]
      if resource_type_token.last[:value] == "file"
        resource_tokens.each_index do |resource_token_idx|
          attr_token = resource_tokens[resource_token_idx]
          if attr_token.first == :NAME and attr_token.last[:value] == 'ensure'
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
