# Public: Test the raw manifest string for lines containing more than 80
# characters. This is DISABLED by default and behaves like the default
# 140chars check by excepting URLs and template() calls.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace (older version)
PuppetLint.new_check(:'80chars') do
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
