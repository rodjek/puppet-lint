# Public: Check the manifest tokens for any comments started with slashes
# (//) and record a warning for each instance found.
PuppetLint.new_check(:slash_comments) do
  def check
    tokens.select { |token|
      token.type == :SLASH_COMMENT
    }.each do |token|
      if PuppetLint.configuration.fix
        token.type = :COMMENT
        notify_type = :fixed
      else
        notify_type = :warning
      end

      notify notify_type, {
        :message    => '// comment found',
        :linenumber => token.line,
        :column     => token.column,
      }
    end
  end
end

# Public: Check the manifest tokens for any comments encapsulated with
# slash-asterisks (/* */) and record a warning for each instance found.
PuppetLint.new_check(:star_comments) do
  def check
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
