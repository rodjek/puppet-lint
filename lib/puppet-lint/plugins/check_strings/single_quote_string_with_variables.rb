# Single quoted strings do not get interpolated, so you should not attempt to
# embed variables in one. This is not a style issue, rather a common mistake.
#
# @example What you have done
#   $foo = 'bar ${baz}'
#
# @example What you should have done
#   $foo = "bar ${baz}"
#
# @style_guide #quoting
# @enabled true
PuppetLint.new_check(:single_quote_string_with_variables) do
  # Check the manifest tokens for any single quoted strings containing an
  # enclosed variable and record an error for each instance found.
  def check
    tokens.select { |r|
      r.type == :SSTRING && r.value.include?('${') && !r.prev_token.prev_token.value.match(%r{inline_(epp|template)})
    }.each do |token|
      notify(
        :error,
        :message => 'single quoted string containing a variable found',
        :line    => token.line,
        :column  => token.column
      )
    end
  end
end
