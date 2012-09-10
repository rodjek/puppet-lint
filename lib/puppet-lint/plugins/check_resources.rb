class PuppetLint::Plugins::CheckResources < PuppetLint::CheckPlugin
  # Public: Check the manifest tokens for any resource titles / namevars that
  # are not quoted and record a warning for each instance found.
  #
  # Return nothing.
  check 'unquoted_resource_title' do
    title_tokens.each do |token|
      if token.type == :NAME
        notify :warning, {
          :message    => 'unquoted resource title',
          :linenumber => token.line,
          :column     => token.column,
        }
      end
    end
  end

  # Public: Check the tokens of each resource instance for an ensure parameter
  # and if found, check that it is the first parameter listed.  If it is not
  # the first parameter, record a warning.
  #
  # Returns nothing.
  check 'ensure_first_param' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]

      param_tokens = resource_tokens.select { |resource_token|
        resource_token.type == :NAME && resource_token.next_code_token.type == :FARROW
      }
      ensure_attr_index = param_tokens.index { |resource_token|
        resource_token.value == 'ensure'
      }

      unless ensure_attr_index.nil?
        if ensure_attr_index > 0
          ensure_token = param_tokens[ensure_attr_index]
          notify :warning, {
            :message    => "ensure found on line but it's not the first attribute",
            :linenumber => ensure_token.line,
            :column     => ensure_token.column,
          }
        end
      end
    end
  end

  check 'duplicate_params' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]].reject { |r|
        formatting_tokens.include? r.type
      }

      seen_params = {}
      level = 0
      resource_tokens.each_with_index do |token, idx|
        case token.type
        when :LBRACE
          level += 1
          next
        when :RBRACE
          seen_params[level] = {}
          level -= 1
          next
        end
        seen_params[level] ||= {}

        if token.type == :FARROW
          prev_token = resource_tokens[idx - 1]
          next unless prev_token.type == :NAME
          if seen_params[level].include? prev_token.value
            notify :error, {
              :message    => 'duplicate parameter found in resource',
              :linenumber => prev_token.line,
              :column     => prev_token.column,
            }
          else
            seen_params[level][prev_token.value] = true
          end
        end
      end
    end
  end

  # Public: Check the tokens of each File resource instance for a mode
  # parameter and if found, record a warning if the value of that parameter is
  # not a quoted string.
  #
  # Returns nothing.
  check 'unquoted_file_mode' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      prev_tokens = tokens[0..resource[:start]]

      lbrace_idx = prev_tokens.rindex { |r|
        r.type == :LBRACE
      }

      resource_type_token = tokens[lbrace_idx].prev_code_token
      if resource_type_token.value == "file"
        resource_tokens.select { |resource_token|
          resource_token.type == :NAME and resource_token.value == 'mode'
        }.each do |resource_token|
          value_token = resource_token.next_code_token.next_code_token
          if {:NAME => true, :NUMBER => true}.include? value_token.type
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

  # Public: Check the tokens of each File resource instance for a mode
  # parameter and if found, record a warning if the value of that parameter is
  # not a 4 digit octal value (0755) or a symbolic mode ('o=rwx,g+r').
  #
  # Returns nothing.
  check 'file_mode' do
    msg = 'mode should be represented as a 4 digit octal value or symbolic mode'
    sym_mode = /\A([ugoa]*[-=+][-=+rstwxXugo]*)(,[ugoa]*[-=+][-=+rstwxXugo]*)*\Z/

    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      prev_tokens = tokens[0..resource[:start]]

      lbrace_idx = prev_tokens.rindex { |r|
        r.type == :LBRACE
      }

      resource_type_token = tokens[lbrace_idx].prev_code_token
      if resource_type_token.value == "file"
        resource_tokens.select { |resource_token|
          resource_token.type == :NAME and resource_token.value == 'mode'
        }.each do |resource_token|
          value_token = resource_token.next_code_token.next_code_token

          break if value_token.value =~ /\A[0-7]{4}\Z/
          break if value_token.type == :VARIABLE
          break if value_token.value =~ sym_mode
          break if value_token.type == :UNDEF

          notify :warning, {
            :message    => msg,
            :linenumber => value_token.line,
            :column     => value_token.column,
          }
        end
      end
    end
  end

  # Public: Check the tokens of each File resource instance for an ensure
  # parameter and record a warning if the value of that parameter looks like
  # a symlink target (starts with a '/').
  #
  # Returns nothing.
  check 'ensure_not_symlink_target' do
    resource_indexes.each do |resource|
      resource_tokens = tokens[resource[:start]..resource[:end]]
      prev_tokens = tokens[0..resource[:start]]

      lbrace_idx = prev_tokens.rindex { |r|
        r.type == :LBRACE
      }

      resource_type_token = tokens[lbrace_idx].prev_code_token
      if resource_type_token.value == "file"
        resource_tokens.select { |resource_token|
          resource_token.type == :NAME and resource_token.value == 'ensure'
        }.each do |ensure_token|
          value_token = ensure_token.next_code_token.next_code_token
          if value_token.value.start_with? '/'
            notify :warning, {
              :message    => 'symlink target specified in ensure attr',
              :linenumber => value_token.line,
              :column     => value_token.column,
            }
          end
        end
      end
    end
  end
end
