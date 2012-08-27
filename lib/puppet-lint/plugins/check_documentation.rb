class PuppetLint::Plugins::CheckDocumentation < PuppetLint::CheckPlugin
  check 'documentation' do
    comment_tokens = {
      :COMMENT => true,
      :MLCOMMENT => true,
      :SLASH_COMMENT => true,
    }

    whitespace_tokens = {
      :WHITESPACE => true,
      :NEWLINE => true,
      :INDENT => true,
    }

    (class_indexes + defined_type_indexes).each do |item_idx|
      prev_token = tokens[item_idx[:start] - 1]
      while (!prev_token.nil?) && whitespace_tokens.include?(prev_token.type)
        prev_token = prev_token.prev_token
      end

      unless (!prev_token.nil?) && comment_tokens.include?(prev_token.type)
        first_token = tokens[item_idx[:start]]
        if first_token.type == :CLASS
          type = 'class'
        else
          type = 'defined type'
        end

        notify :warning, {
          :message    => "#{type} not documented",
          :linenumber => first_token.line,
          :column     => first_token.column,
        }
      end
    end
  end
end
