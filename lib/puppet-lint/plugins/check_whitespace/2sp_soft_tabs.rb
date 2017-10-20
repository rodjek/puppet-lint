# In order to comply with the style guide, manifests must use 2 space
# characters when indenting.
#
# @example What you have done
#   file { '/tmp/foo':
#       ensure => present,
#   }
#
# @example What you should have done
#   file { '/tmp/foo':
#     ensure => present,
#   }
#
# @style_guide #spacing-indentation-and-whitespace
# @enabled true
PuppetLint.new_check(:'2sp_soft_tabs') do
  # Check the manifest tokens for any indentation not using 2 space soft tabs
  # and record an error for each instance found.
  def check
    tokens.select { |r|
      r.type == :INDENT
    }.reject { |r|
      r.value.length.even?
    }.each do |token|
      notify(
        :error,
        :message => 'two-space soft tabs not used',
        :line    => token.line,
        :column  => token.column
      )
    end
  end
end
