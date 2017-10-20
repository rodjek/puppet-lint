# When defining variables you must only use numbers, lowercase letters and
# underscores. You should not use camelCasing, as it introduces inconsistency
# in style.
#
# @example What you have done
#   $packageName
#
# @example What you should have done
#   $package_name
#
# @style_guide #variable-format
# @enabled true
PuppetLint.new_check(:variable_is_lowercase) do
  VARIABLE_LOWERCASE_TYPES = Set[:VARIABLE, :UNENC_VARIABLE]

  # Test the manifest tokens for variables that contain an uppercase letter
  # and record a warning for each instance found.
  def check
    tokens.select { |r|
      VARIABLE_LOWERCASE_TYPES.include?(r.type)
    }.each do |token|
      next unless token.value.gsub(%r{\[.+?\]}, '') =~ %r{[A-Z]}

      notify(
        :warning,
        :message => 'variable contains an uppercase letter',
        :line    => token.line,
        :column  => token.column
      )
    end
  end
end
