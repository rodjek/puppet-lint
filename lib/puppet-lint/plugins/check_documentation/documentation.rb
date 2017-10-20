# All Puppet classes and defines should be documented via comments directly
# above the start of the code.
#
# @example What you have done
#   class ntp {}
#
# @example What you should have done
#   # Install and configure an NTP server
#   # You should feel free to expand on this and document any parameters etc
#   class ntp {}
#
# @style_guide #public-and-private
# @enabled true
PuppetLint.new_check(:documentation) do
  COMMENT_TOKENS = Set[:COMMENT, :MLCOMMENT, :SLASH_COMMENT]
  WHITESPACE_TOKENS = Set[:WHITESPACE, :NEWLINE, :INDENT]

  # Check the manifest tokens for any class or defined type that does not have
  # a comment directly above it (hopefully, explaining the usage of it) and
  # record a warning for each instance found.
  def check
    (class_indexes + defined_type_indexes).each do |item_idx|
      comment_token = find_comment_token(item_idx[:tokens].first)

      next unless comment_token.nil?

      first_token = item_idx[:tokens].first
      type = if first_token.type == :CLASS
               'class'
             else
               'defined type'
             end

      notify(
        :warning,
        :message => "#{type} not documented",
        :line    => first_token.line,
        :column  => first_token.column
      )
    end
  end

  def find_comment_token(start_token)
    prev_token = start_token.prev_token
    while !prev_token.nil? && WHITESPACE_TOKENS.include?(prev_token.type)
      prev_token = prev_token.prev_token
    end

    return if prev_token.nil?

    prev_token if COMMENT_TOKENS.include?(prev_token.type)
  end
end
