# Public: Check the manifest tokens for any single quoted strings containing
# a enclosed variable and record an error for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#quoting
PuppetLint.new_check(:single_quote_string_with_variables) do
  def check
    invalid_tokens = tokens.select do |token|
      token.type == :SSTRING && token.value.include?('${') && !token.prev_token.prev_token.value.match(%r{inline_(epp|template)})
    end

    invalid_tokens.each do |token|
      notify(
        :error,
        message: 'single quoted string containing a variable found',
        line: token.line,
        column: token.column,
        description: 'Check the manifest tokens for any single quoted strings containing '\
          'a enclosed variable and record an error for each instance found.',
        help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#quoting',
      )
    end
  end
end
