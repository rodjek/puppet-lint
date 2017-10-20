# In order to comply with the style guide, manifests must not use hard tab
# characters (\t) in the whitespace.
#
# @example What you have done
#   file { '/tmp/foo':
#           ensure => present,
#   }
#
# @example What you should have done
#   file { '/tmp/foo'::
#     ensure => present,
#   }
#
# @style_guide #spacing-indentation-and-whitespace
# @enabled true
PuppetLint.new_check(:hard_tabs) do
  WHITESPACE_TYPES = Set[:INDENT, :WHITESPACE]

  # Check the manifest tokens for any :WHITESPACE or :INDENT tokens that
  # contain hard tab (\t) characters and record an error for each instance
  # found.
  def check
    tokens.select { |r|
      WHITESPACE_TYPES.include?(r.type) && r.value.include?("\t")
    }.each do |token|
      notify(
        :error,
        :message => 'tab character found',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    problem[:token].value.gsub!("\t", '  ')
  end
end
