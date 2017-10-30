# Public: Test the manifest tokens for any selectors embedded within resource
# declarations and record a warning for each instance found.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#keep-resource-declarations-simple
PuppetLint.new_check(:selector_inside_resource) do
  def check
    resource_indexes.each do |resource|
      resource[:tokens].each do |token|
        next unless token.type == :FARROW && token.next_code_token.type == :VARIABLE
        next if token.next_code_token.next_code_token.nil?
        next unless token.next_code_token.next_code_token.type == :QMARK

        notify(
          :warning,
          :message => 'selector inside resource block',
          :line    => token.line,
          :column  => token.column
        )
      end
    end
  end
end
