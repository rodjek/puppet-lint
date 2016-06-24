# Public: Test the manifest tokens for variables that contain a dash and
# record a warning for each instance found.
PuppetLint.new_check(:variable_contains_dash) do
  VARIABLE_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  def check
    tokens.select { |r|
      VARIABLE_TYPES.include? r.type
    }.each do |token|
      if token.value.gsub(/\[.+?\]/, '').match(/-/)
        notify :warning, {
          :message => 'variable contains a dash',
          :line    => token.line,
          :column  => token.column,
        }
      end
    end
  end
end

# Public: Test the manifest tokens for variables that contain an upper case
# character and record a warning
PuppetLint.new_check(:variable_contains_upcase) do
  def check
    tokens.select { |r|
      VARIABLE_TYPES.include? r.type
    }.each do |token|
      if token.value.match(/[A-Z]/)
        notify :warning, {
          :message => 'variable contains a capital letter',
          :line    => token.line,
          :column  => token.column,
        }
      end
    end
  end
end
