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

PuppetLint.new_check(:variable_startswith_number) do
  VARIABLE_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  def check
    tokens.select { |r|
      VARIABLE_TYPES.include? r.type
    }.each do |token|
      if token.value.gsub(/\[.+?\].+?/, '').match(/^[0-9]/)
        notify :warning, {
          :message => 'variable starts with a number',
          :line    => token.line,
          :column  => token.column,
        }
      end
    end
  end
end

