# Public: Check the manifest tokens for any indentation not using 2 space soft
# tabs and record an error for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:'2sp_soft_tabs') do
  def check
    indents = tokens.select { |token| token.type == :INDENT }

    invalid_indents = indents.reject { |token| token.value.length.even? }

    invalid_indents.each do |token|
      notify(
        :error,
        message: 'two-space soft tabs not used',
        line: token.line,
        column: token.column,
        description: 'Check the manifest tokens for any indentation not using 2 space soft tabs and record an error for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace',
      )
    end
  end
end
