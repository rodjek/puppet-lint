class PuppetLint::Plugins::CheckDocumentation < PuppetLint::CheckPlugin
  check 'documentation' do
    (class_indexes + defined_type_indexes).each do |item_idx|
      prev_token = tokens[0..item_idx[:start] - 1].reject { |token|
        [:WHITESPACE, :NEWLINE, :INDENT].include? token.type
      }.last

      unless [:COMMENT, :MLCOMMENT, :SLASH_COMMENT].include? prev_token.type
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
