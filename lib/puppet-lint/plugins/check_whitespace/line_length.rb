# A utility class for checking the length of a given string.
class PuppetLint::LineLengthCheck
  # Check the current line to determine if it is more than character_count
  # and record a warning if an instance is found. The only exceptions
  # to this rule are lines containing URLs and template() calls which would hurt
  # readability if split.
  #
  # @param line_number [Integer] The line number of the current line.
  # @param content [String] The content of the current line.
  # @param character_count [Integer] The maximum number of characters allowed
  #
  # @return problem [Array] An array containing a description of the problem.
  # Can be passed directly to notify..
  def self.check(line_number, content, character_count)
    return if content.include? '://'
    return if content.include? 'template('
    return unless content.scan(%r{.}mu).size > character_count

    [
      :warning,
      message: "line has more than #{character_count} characters",
      line: line_number,
      column: character_count,
      description: 'Test the raw manifest string for lines containing more than #{character_count} characters and record a warning for each instance found. '\
        'The only exceptions to this rule are lines containing URLs and template() calls which would hurt readability if split.',
      help_uri: 'https://puppet.com/docs/puppet/latest/style_guide.html#spacing-indentation-and-whitespace',
    ]
  end
end
