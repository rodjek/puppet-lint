# Relationship declarations with the chaining syntax should only be used in the
# "left to right" direction.
#
# @example What you have done
#   Service['httpd'] <- Package['httpd']
#
# @example What you should have done
#   Package['httpd'] -> Service['httpd']
#
# @style_guide #chaining-arrow-syntax
# @enabled true
PuppetLint.new_check(:right_to_left_relationship) do
  # Test the manifest tokens for any right-to-left (<-) chaining operators and
  # record a warning for each instance found.
  def check
    tokens.select { |r| r.type == :OUT_EDGE }.each do |token|
      notify(
        :warning,
        :message =>  'right-to-left (<-) relationship',
        :line    => token.line,
        :column  => token.column
      )
    end
  end
end
