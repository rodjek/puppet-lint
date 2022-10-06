# Public: Check the manifest tokens for any puppet:// URL strings where the
# path section doesn't start with modules/ and record a warning for each
# instance found.
#
# No style guide reference
PuppetLint.new_check(:puppet_url_without_modules) do
  def check
    puppet_urls = tokens.select do |token|
      (token.type == :SSTRING || token.type == :STRING || token.type == :DQPRE) && token.value.start_with?('puppet://')
    end

    invalid_urls = puppet_urls.reject do |token|
      token.value[%r{puppet://.*?/(.+)}, 1]&.start_with?('modules/')
    end

    invalid_urls.each do |token|
      notify(
        :warning,
        message: 'puppet:// URL without modules/ found',
        line: token.line,
        column: token.column,
        token: token,
        description: 'Check the manifest tokens for any puppet:// URL strings where the path section doesn\'t start with modules/ and record a warning for each instance found.',
        help_uri: nil,
      )
    end
  end

  def fix(problem)
    problem[:token].value.gsub!(%r{(puppet://.*?/)}, '\1modules/')
  end
end
