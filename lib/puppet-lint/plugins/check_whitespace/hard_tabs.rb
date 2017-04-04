# Public: Check the raw manifest string for lines containing hard tab
# characters and record an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:hard_tabs) do
  WHITESPACE_TYPES = Set[:INDENT, :WHITESPACE]

  def check
    tokens.select { |r|
      WHITESPACE_TYPES.include?(r.type) && r.value.include?("\t")
    }.each do |token|
      notify :error, {
        :message => 'tab character found',
        :line    => token.line,
        :column  => token.column,
        :token   => token,
      }
    end
  end

  def fix(problem)
    problem[:token].value.gsub!("\t", '  ')
  end
end
