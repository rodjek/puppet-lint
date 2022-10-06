# Public: Test the raw manifest string for lines containing more than 140
# characters and record a warning for each instance found.  The only exceptions
# to this rule are lines containing URLs and template() calls which would hurt
# readability if split.
#
# https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace
PuppetLint.new_check(:'140chars') do
  def check
    manifest_lines.each_with_index do |line, idx|
      result = PuppetLint::LineLengthCheck.check(idx + 1, line, 140)

      next if result.nil?
      notify(*result)
    end
  end
end
