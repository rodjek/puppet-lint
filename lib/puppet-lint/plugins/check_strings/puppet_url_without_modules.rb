# When using puppet:// URLs, you should ensure that the path starts with
# `modules/` (as the most common mount point in the Puppet fileserver).
#
# @example What you have done
#   file { '/etc/apache/apache2.conf':
#     source => 'puppet:///apache/etc/apache/apache2.conf',
#   }
#
# @example What you should have done
#   file { '/etc/apache/apache2.conf':
#     source => 'puppet:///modules/apache/etc/apache/apache2.conf',
#   }
#
# @enabled true
PuppetLint.new_check(:puppet_url_without_modules) do
  # Check the manifest tokens for any puppet:// URL strings where the path
  # section doesn't start with modules/ and record a warning for each instance
  # found.
  def check
    tokens.select { |token|
      (token.type == :SSTRING || token.type == :STRING || token.type == :DQPRE) && token.value.start_with?('puppet://')
    }.reject { |token|
      token.value[%r{puppet://.*?/(.+)}, 1].start_with?('modules/') unless token.value[%r{puppet://.*?/(.+)}, 1].nil?
    }.each do |token|
      notify(
        :warning,
        :message => 'puppet:// URL without modules/ found',
        :line    => token.line,
        :column  => token.column,
        :token   => token
      )
    end
  end

  def fix(problem)
    problem[:token].value.gsub!(%r{(puppet://.*?/)}, '\1modules/')
  end
end
