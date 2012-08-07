class PuppetLint::Plugins::CheckComments < PuppetLint::CheckPlugin
  # Public: Check the manifest tokens for any comments started with slashes
  # (//) and record a warning for each instance found.
  #
  # Returns nothing.
  check 'slash_comments' do
    tokens.select { |token|
      token.type == :SLASH_COMMENT
    }.each do |token|
      notify :warning, {
        :message    => '// comment found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end

  # Public: Check the manifest tokens for any comments encapsulated with
  # slash-asterisks (/* */) and record a warning for each instance found.
  #
  # Returns nothing.
  check 'star_comments' do
    tokens.select { |token|
      token.type == :MLCOMMENT
    }.each do |token|
      notify :warning, {
        :message    => '/* */ comment found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end
