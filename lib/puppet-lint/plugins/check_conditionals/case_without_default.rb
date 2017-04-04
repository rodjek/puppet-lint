# Public: Test the manifest tokens for any case statements that do not
# contain a "default" case and record a warning for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#defaults-for-case-statements-and-selectors
PuppetLint.new_check(:case_without_default) do
  def check
    case_indexes = []

    tokens.each_index do |token_idx|
      if tokens[token_idx].type == :CASE
        depth = 0
        tokens[(token_idx + 1)..-1].each_index do |case_token_idx|
          idx = case_token_idx + token_idx + 1
          if tokens[idx].type == :LBRACE
            depth += 1
          elsif tokens[idx].type == :RBRACE
            depth -= 1
            if depth == 0
              case_indexes << {:start => token_idx, :end => idx}
              break
            end
          end
        end
      end
    end

    case_indexes.each_with_index do |kase,kase_index|
      case_tokens = tokens[kase[:start]..kase[:end]]

      case_indexes[(kase_index + 1)..-1].each do |successor_kase|
        case_tokens -= tokens[successor_kase[:start]..successor_kase[:end]]
      end

      unless case_tokens.index { |r| r.type == :DEFAULT }
        notify :warning, {
          :message => 'case statement without a default case',
          :line    => case_tokens.first.line,
          :column  => case_tokens.first.column,
        }
      end
    end
  end
end
