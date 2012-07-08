# Resources
# http://docs.puppetlabs.com/guides/style_guide.html#resources

class PuppetLint::Plugins::CheckResources < PuppetLint::CheckPlugin
  check 'unquoted_resource_title' do
    title_tokens.each do |token|
      if token.type == :NAME
        notify :warning, :message =>  "unquoted resource title", :linenumber => token.line
      end
    end
  end

  check 'ensure_first_param' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]].reject { |r|
        formatting_tokens.include? r.type
      }

      ensure_attr_index = resource_tokens.index { |token|
        token.type == :NAME and token.value == 'ensure'
      }

      unless ensure_attr_index.nil?
        if ensure_attr_index > 1
          ensure_token = resource_tokens[ensure_attr_index]
          notify :warning, {
            :message =>  "ensure found on line but it's not the first attribute",
            :linenumber => ensure_token.line,
            :column     => ensure_token.column,
          }
        end
      end
    end
  end

  check 'unquoted_file_mode' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]].reject { |r|
        formatting_tokens.include? r.type
      }

      stripped_tokens = tokens[0..resource[:start]].reject { |r|
        formatting_tokens.include? r.type
      }

      res_type_idx = stripped_tokens.rindex { |r|
        r.type == :LBRACE
      } - 1

      resource_type_token = stripped_tokens[res_type_idx]
      if resource_type_token.value == "file"
        resource_tokens.each_index do |resource_token_idx|
          attr_token = resource_tokens[resource_token_idx]
          if attr_token.type == :NAME and attr_token.value == 'mode'
            value_token = resource_tokens[resource_token_idx + 2]
            if value_token.type == :NAME
              notify :warning, {
                :message    => 'unquoted file mode',
                :linenumber => value_token.line,
                :column     => value_token.column,
              }
            end
          end
        end
      end
    end
  end

  check 'file_mode' do
    msg = 'mode should be represented as a 4 digit octal value or symbolic mode'
    sym_mode = /\A([ugoa]*[-=+][-=+rstwxXugo]*)(,[ugoa]*[-=+][-=+rstwxXugo]*)*\Z/

    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]].reject { |r|
        formatting_tokens.include? r.type
      }

      stripped_tokens = tokens[0..resource[:start]].reject { |r|
        formatting_tokens.include? r.type
      }

      res_type_idx = stripped_tokens.rindex { |r|
        r.type == :LBRACE
      } - 1

      resource_type_token = stripped_tokens[res_type_idx]
      if resource_type_token.value == "file"
        resource_tokens.each_index do |resource_token_idx|
          attr_token = resource_tokens[resource_token_idx]
          if attr_token.type == :NAME and attr_token.value == 'mode'
            value_token = resource_tokens[resource_token_idx + 2]

            break if value_token.value =~ /\d{4}/
            break if value_token.type == :VARIABLE
            break if value_token.value =~ sym_mode

            notify :warning, {
              :message    => msg,
              :linenumber => value_token.line,
              :column     => value_token.column,
            }
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
              notify :warning, :message =>  "symlink target specified in ensure attr", :linenumber => value_token.last[:line]
            end
          end
        end
      end
    end
  end
end
