# Public: Test the raw manifest string for lines containing more than 140
# characters and record a warning for each instance found.  The only exceptions
# to this rule are lines containing URLs and template() calls which would hurt
# readability if split.
#
# https://docs.puppet.com/guides/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:'140chars') do
  def check
    manifest_lines.each_with_index do |line, idx|
      unless line =~ /:\/\// || line =~ /template\(/
        if line.scan(/./mu).size > 140
          notify :warning, {
            :message => 'line has more than 140 characters',
            :line    => idx + 1,
            :column  => 140,
          }
        end
      end
    end
  end
end
