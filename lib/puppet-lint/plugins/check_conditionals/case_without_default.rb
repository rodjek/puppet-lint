# Case statements should have default cases. Additionally, the default case
# should fail the catalogue compilation when the resulting behaviour can not be
# predicted on the majority of platforms the module will be used on. If you
# want the default case to be "do nothing", include it as an explicit `default:
# {}` for clarity's sake.
#
# @example What you have done
#   case $::operatingsystem {
#     centos: {
#       $version = '1.2.3'
#     }
#     solaris: {
#       $version = '3.2.1'
#     }
#   }
#
# @example What you should have done
#   case $::operatingsystem {
#     centos: {
#       $version = '1.2.3'
#     }
#     solaris: {
#       $version = '3.2.1'
#     }
#     default: {
#       fail("Module ${module_name} is not supported on ${::operatingsystem}")
#     }
#   }
#
# @style_guide #defaults-for-case-statements-and-selectors
# @enabled true
PuppetLint.new_check(:case_without_default) do
  # Test the manifest tokens for any case statements that do not contain a
  # "default" case and record a warning for each instance found.
  def check
    case_indexes = []

    tokens.each_index do |token_idx|
      next unless tokens[token_idx].type == :CASE

      depth = 0
      tokens[(token_idx + 1)..-1].each_index do |case_token_idx|
        idx = case_token_idx + token_idx + 1
        if tokens[idx].type == :LBRACE
          depth += 1
        elsif tokens[idx].type == :RBRACE
          depth -= 1
          if depth.zero?
            case_indexes << { :start => token_idx, :end => idx }
            break
          end
        end
      end
    end

    case_indexes.each_with_index do |kase, kase_index|
      case_tokens = tokens[kase[:start]..kase[:end]]

      case_indexes[(kase_index + 1)..-1].each do |successor_kase|
        case_tokens -= tokens[successor_kase[:start]..successor_kase[:end]]
      end

      next if case_tokens.index { |r| r.type == :DEFAULT }

      notify(
        :warning,
        :message => 'case statement without a default case',
        :line    => case_tokens.first.line,
        :column  => case_tokens.first.column
      )
    end
  end
end
