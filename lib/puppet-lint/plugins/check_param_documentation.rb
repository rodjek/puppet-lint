# Check that all parameters have documentation blocks,
# and if they have a default, it is documented
#
PuppetLint.new_check(:param_documentation) do
  def check
    (class_indexes + defined_type_indexes).each do |item_idx|

      parameters = {}

      # Skip comments for now
      first = item_idx[:tokens][0].next_code_token

      # fp will be the open paren if this is a parameterised class
      fp = first.next_code_token

      # Search through the first parens, as they will contain the
      # parameters for this class
      if fp.type == :LPAREN then
        while fp.next_code_token.type != :RPAREN && fp.type != :RPAREN
          # There are some parameters defined here
          variable = fp.next_code_token
          valuetokens = []
          valuetokens.push(variable.next_code_token.next_code_token)

          # values for the variables might contain parens themselves,
          # so track depth as we search
          depth = 0
          until (depth == 0 && (valuetokens.last.type == :COMMA or valuetokens.last.type == :RPAREN))
            if valuetokens.last.type == :LPAREN then
              depth += 1
            end
            if valuetokens.last.type == :RPAREN then
              depth -= 1
            end
            valuetokens.push(valuetokens.last.next_code_token)
          end

          parameters[variable.value] = valuetokens[0..-2]
          fp = valuetokens.last
        end
      end

      # Parameters is now a hash of the parameters for the class or defined type

      # The first token is actually the first code token, so trace back
      # to the first actual token which will likely be a comment
      current = item_idx[:tokens][0]
      while true
        if !current.prev_token.nil? then
          current = current.prev_token
        else
          break
        end
      end

      # Current is now the first token in the manifest
      first_token = current
      parameters.each do | name, value |

        # Required parameters have no default
        required = false
        if (!value.size.nil? and value.size == 0) then
          required = true
        end

        current = first_token
        while (WHITESPACE_TOKENS + COMMENT_TOKENS).include?(current.type)
          if ( current.value.include?("[*#{name}*]")) then

            # the next token will always be a newline, the one after should be
            # stating whether it's optional and starting the description
            if (!current.next_token.nil? and !current.next_token.next_token.nil?) then
              current = current.next_token.next_token
            else
              notify :warning, {
                :message => "#{name} parameter not documented",
                :line    => current.line,
                :column  => current.column,
              }
              break
            end

            if !(current.value.include?('optional') or current.value.include?('required')) then
              notify :warning, {
                :message => "#{name} parameter required/optional not documented",
                :line    => current.line,
                :column  => current.column,
              }
            end

            # Now search for the 'Defaults to' and ensure it's correct. If we hit a code
            # token or a [* then something is wrong. There is a slight chance someone might
            # want to include [* in their description but this is pretty unlikely.
            if !required then
              while true
                vstr = ''
                value.each do |v|
                  # Variable tokens have their leading $ stripped, but default doc should have it
                  if v.type == :VARIABLE then
                    vstr += '$'
                  end
                  vstr += v.value
                end

                if current.value.to_s.include?('Defaults to ') and current.value.to_s.include?(vstr) then
                  break
                elsif (current.value.include?('[*') or current.next_token.nil?)
                  notify :warning, {
                    :message => "#{name} parameter default not documented",
                    :line    => current.line,
                    :column  => current.column,
                  }
                  break
                elsif !(WHITESPACE_TOKENS + COMMENT_TOKENS).include?(current.type) then
                  notify :warning, {
                    :message => "#{name} parameter default not documented",
                    :line    => current.line,
                    :column  => current.column,
                  }
                  break
                else
                  current = current.next_token
                end
              end
            end
          end
          if !current.next_token.nil? then
            current = current.next_token
          else
            notify :warning, {
              :message => "#{name} parameter not documented",
              :line    => current.line,
              :column  => current.column,
            }
            break
          end
        end
      end
    end
  end
end
