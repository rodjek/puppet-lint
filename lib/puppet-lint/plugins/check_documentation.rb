# Public: Check the manifest tokens for any class or defined type that does not
# have a comment directly above it (hopefully, explaining the usage of it) and
# record a warning for each instance found.
PuppetLint.new_check(:documentation) do
  COMMENT_TOKENS = Set[:COMMENT, :MLCOMMENT, :SLASH_COMMENT]
  WHITESPACE_TOKENS = Set[:WHITESPACE, :NEWLINE, :INDENT]

  def check
    (class_indexes + defined_type_indexes).each do |item_idx|
      prev_token = item_idx[:tokens].first.prev_token
      while (!prev_token.nil?) && WHITESPACE_TOKENS.include?(prev_token.type)
        prev_token = prev_token.prev_token
      end

      unless (!prev_token.nil?) && COMMENT_TOKENS.include?(prev_token.type)
        first_token = item_idx[:tokens].first
        if first_token.type == :CLASS
          type = 'class'
        else
          type = 'defined type'
        end

        notify :warning, {
          :message => "#{type} not documented",
          :line    => first_token.line,
          :column  => first_token.column,
        }
      end
    end
  end
end
