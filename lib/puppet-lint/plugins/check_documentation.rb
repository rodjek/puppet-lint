class PuppetLint::Plugins::CheckDocumentation < PuppetLint::CheckPlugin
  def whitespace_tokens
    @whitespace_tokens ||= {
      :WHITESPACE => true,
      :NEWLINE => true,
      :INDENT => true,
    }
  end

  def comment_tokens
    @comment_tokens ||= {
      :COMMENT => true,
      :MLCOMMENT => true,
      :SLASH_COMMENT => true,
    }
  end

  check 'documentation' do
    (class_indexes + defined_type_indexes).each do |item_idx|
      prev_token = tokens[item_idx[:start] - 1]
      while whitespace_tokens.include? prev_token.type
        prev_token = prev_token.prev_token
      end

      unless comment_tokens.include? prev_token.type
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
