# When defining variables you should only use letters, numbers and underscores.
# You should specifically not make use of dashes.
#
# @example What you have done
#   $foo-bar
#
# @example What you should have done
#   $foo_bar
#
# @style_guide #variable-format
# @enabled true
PuppetLint.new_check(:variable_contains_dash) do
  VARIABLE_DASH_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  # Test the manifest tokens for variables that contain a dash and record a
  # warning for each instance found.
  def check
    tokens.select { |r|
      VARIABLE_DASH_TYPES.include?(r.type)
    }.each do |token|
      next unless token.value.gsub(%r{\[.+?\]}, '') =~ %r{-}

      notify(
        :warning,
        :message => 'variable contains a dash',
        :line    => token.line,
        :column  => token.column
      )
    end
  end
end
