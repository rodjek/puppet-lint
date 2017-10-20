# It is a good practice to avoid putting resources in the top scope (outside of
# any classes or defined types) as it can lead to unexpected behaviour. If you
# need to ensure that a resource is defined on all hosts, it's better to
# explicitly put it in the `default` node manifest.
#
# @enabled false
# @deprecated While keeping all your resources inside classes or defined types
#   is considered a good practice, this is not mentioned in the style guide and
#   so this check has been deprecated and will be moved into a separate plugin
#   in the future.
PuppetLint.new_check(:code_on_top_scope) do
  # Test that there are no code tokens defined outside of a class or defined
  # type.
  def check
    class_scope = (class_indexes + defined_type_indexes).map { |e| tokens[e[:start]..e[:end]] }.flatten
    top_scope   = tokens - class_scope

    top_scope.each do |token|
      next if formatting_tokens.include?(token.type)

      notify(
        :warning,
        :message => "code outside of class or define block - #{token.value}",
        :line    => token.line,
        :column  => token.column
      )
    end
  end
end
PuppetLint.configuration.send('disable_code_on_top_scope')
