# Public: Test the manifest tokens for any classes or defined types that are
# defined inside another class.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#nested-classes-or-defined-types
PuppetLint.new_check(:nested_classes_or_defines) do
  TOKENS = Set[:CLASS, :DEFINE]

  def check
    class_indexes.each do |class_idx|
      # Skip the first token so that we don't pick up the first :CLASS
      class_tokens = class_idx[:tokens][1..-1]

      class_tokens.each do |token|
        next unless TOKENS.include?(token.type)
        next if token.next_code_token.type == :LBRACE
        type = (token.type == :CLASS) ? 'class' : 'defined type'

        notify(
          :warning,
          message: "#{type} defined inside a class",
          line: token.line,
          column: token.column,
          description: 'Test the manifest tokens for any classes or defined types that are defined inside another class.',
          help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#nested-classes-or-defined-types',
        )
      end
    end
  end
end
