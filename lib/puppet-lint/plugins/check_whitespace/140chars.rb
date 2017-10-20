# Your manifests should not contain any lines longer than 140 characters.
#
# @style_guide #spacing-indentation-and-whitespace.
# @enabled true
PuppetLint.new_check(:'140chars') do
  # Test the raw manifest string for lines containing more than 140 characters
  # and record a warning for each instance found.
  def check
    manifest_lines.each_with_index do |line, idx|
      next if line =~ %r{://} || line =~ %r{template\(}
      next unless line.scan(%r{.}mu).size > 140

      notify(
        :warning,
        :message => 'line has more than 140 characters',
        :line    => idx + 1,
        :column  => 140
      )
    end
  end
end
