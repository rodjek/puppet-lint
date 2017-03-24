# Public: Test the manifest tokens for any selectors embedded within resource
# declarations and record a warning for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#keep-resource-declarations-simple
PuppetLint.new_check(:selector_inside_resource) do
  def check
    resource_indexes.each do |resource|
      resource[:tokens].each do |token|
        if token.type == :FARROW
          if token.next_code_token.type == :VARIABLE
            unless token.next_code_token.next_code_token.nil?
              if token.next_code_token.next_code_token.type == :QMARK
                notify :warning, {
                  :message => 'selector inside resource block',
                  :line    => token.line,
                  :column  => token.column,
                }
              end
            end
          end
        end
      end
    end
  end
end
