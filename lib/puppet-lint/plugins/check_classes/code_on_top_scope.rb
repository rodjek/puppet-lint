# Public: Test that no code is outside of a class or define scope.
#
# No style guide reference
PuppetLint.new_check(:code_on_top_scope) do
  def check
    class_scope = (class_indexes + defined_type_indexes).map { |e| tokens[e[:start]..e[:end]] }.flatten
    top_scope   = tokens - class_scope

    top_scope.each do |token|
      unless formatting_tokens.include? token.type
        notify :warning, {
          :message => "code outside of class or define block - #{token.value}",
          :line    => token.line,
          :column  => token.column
        }
      end
    end
  end
end
PuppetLint.configuration.send("disable_code_on_top_scope")
