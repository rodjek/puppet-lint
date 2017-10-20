# Your manifests should not contain any lines longer than 80 characters.
#
# @style_guide #spacing-indentation-and-whitespace
# @enabled false
# @deprecated The style guide has been updated with a maximum line length of
#   140 characters, so this check has been deprecated in favour of the
#   `140chars` check.
PuppetLint.new_check(:'80chars') do
  # Test the raw manifest string for lines containing more than 80 characters.
  def check
    manifest_lines.each_with_index do |line, idx|
      next if line =~ %r{://} || line =~ %r{template\(}
      next unless line.scan(%r{.}mu).size > 80

      notify(
        :warning,
        :message => 'line has more than 80 characters',
        :line    => idx + 1,
        :column  => 80
      )
    end
  end
end
PuppetLint.configuration.send('disable_80chars')
