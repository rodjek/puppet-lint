COMMANDS = Array['command', 'onlyif', 'unless']
INTERPOLATED_STRINGS = Array[:DQPRE, :DQMID]
USELESS_CHARS = Array[:WHITESPACE, :COMMA]

PuppetLint.new_check(:check_unsafe_interpolations) do
  def check
    # Gather any exec commands' resources into an array
    exec_resources = resource_indexes.filter_map do |resource|
      resource_parameters = resource[:param_tokens].map(&:value)
      resource if resource[:type].value == 'exec' && !(COMMANDS & resource_parameters).empty?
    end

    # Iterate over title tokens and raise a warning if any are variables
    unless get_exec_titles.empty?
      get_exec_titles.each do |title|
        check_unsafe_title(title)
      end
    end

    # Iterate over each command found in any exec
    exec_resources.each do |command_resources|
      check_unsafe_interpolations(command_resources)
    end
  end

  # Iterate over the tokens in a title and raise a warning if an interpolated variable is found
  def check_unsafe_title(title)
    title.each do |token|
      notify_warning(token.next_code_token) if interpolated?(token)
    end
  end

  # Iterates over an exec resource and if a command, onlyif or unless paramter is found, it is checked for unsafe interpolations
  def check_unsafe_interpolations(command_resources)
    command_resources[:tokens].each do |token|
      # Skip iteration if token isn't a command of type :NAME
      next unless COMMANDS.include?(token.value) && token.type == :NAME
      # Don't check the command if it is parameterised
      next if parameterised?(token)

      check_command(token).each do |t|
        notify_warning(t)
      end
    end
  end

  # Raises a warning given a token and message
  def notify_warning(token)
    notify :warning,
           message: "unsafe interpolation of variable '#{token.value}' in exec command",
           line: token.line,
           column: token.column
  end

  # Iterates over the tokens in a command and adds it to an array of violations if it is an input variable
  def check_command(token)
    # Initialise variables needed in while loop
    rule_violations = []
    current_token = token

    # Iterate through tokens in command
    while current_token.type != :NEWLINE
      # Check if token is a varibale and if it is parameterised
      rule_violations.append(current_token.next_code_token) if interpolated?(current_token)
      current_token = current_token.next_token
    end

    rule_violations
  end

  # A command is parameterised if its args are placed in an array
  # This function checks if the current token is a :FARROW and if so, if it is followed by an LBRACK
  def parameterised?(token)
    current_token = token
    while current_token.type != :NEWLINE
      return true if current_token.type == :FARROW && current_token.next_token.next_token.type == :LBRACK

      current_token = current_token.next_token
    end
  end

  # This function is a replacement for puppet_lint's title_tokens function which assumes titles have single quotes
  # This function adds a check for titles in double quotes where there could be interpolated variables
  def get_exec_titles
    result = []
    tokens.each_with_index do |_token, token_idx|
      next if tokens[token_idx].value != 'exec'

      # We have a resource declaration. Now find the title
      tokens_array = []
      # Check if title is an array
      if tokens[token_idx]&.next_code_token&.next_code_token&.type == :LBRACK
        # Get the start and end indices of the array of titles
        array_start_idx = tokens.rindex { |r| r.type == :LBRACK }
        array_end_idx = tokens.rindex { |r| r.type == :RBRACK }

        # Grab everything within the array
        title_array_tokens = tokens[(array_start_idx + 1)..(array_end_idx - 1)]
        tokens_array.concat(title_array_tokens.reject do |token|
          USELESS_CHARS.include?(token.type)
        end)
        result << tokens_array
      # Check if title is double quotes string
      elsif tokens[token_idx].next_code_token.next_code_token.type == :DQPRE
        # Find the start and end of the title
        title_start_idx = tokens.find_index(tokens[token_idx].next_code_token.next_code_token)
        title_end_idx = title_start_idx + index_offset_for(':', tokens[title_start_idx..tokens.length])

        result << tokens[title_start_idx..title_end_idx]
      # Title is in single quotes
      else
        tokens_array.concat([tokens[token_idx].next_code_token.next_code_token])

        result << tokens_array
      end
    end
    result
  end

  def interpolated?(token)
    INTERPOLATED_STRINGS.include?(token.type)
  end

  # Finds the index offset of the next instance of `value` in `tokens_slice` from the original index
  def index_offset_for(value, tokens_slice)
    tokens_slice.each_with_index do |token, i|
      return i if value.include?(token.value)
    end
  end
end
