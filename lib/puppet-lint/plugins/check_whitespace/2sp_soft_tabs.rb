# Public: Check the manifest tokens for any indentation not using 2 space soft
# tabs and record an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:'2sp_soft_tabs') do
  def check
    tokens.select { |r|
      r.type == :INDENT
    }.reject { |r|
      r.value.length % 2 == 0
    }.each do |token|
      notify :error, {
        :message => 'two-space soft tabs not used',
        :line    => token.line,
        :column  => token.column,
      }
    end
  end
end
