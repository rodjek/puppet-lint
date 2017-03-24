# Public: Check the manifest tokens for any single quoted strings containing
# a enclosed variable and record an error for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#quoting
PuppetLint.new_check(:single_quote_string_with_variables) do
  def check
    tokens.select { |r|
      r.type == :SSTRING && r.value.include?('${') && (! r.prev_token.prev_token.value.match(%r{inline_(epp|template)}) )
    }.each do |token|
      notify :error, {
        :message => 'single quoted string containing a variable found',
        :line    => token.line,
        :column  => token.column,
      }
    end
  end
end
