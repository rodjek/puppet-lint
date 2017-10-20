# The following popular method SHOULD NOT be used because it is not compatible
# with Puppet 2.6.2 and earlier.
#
# @example What you have done
#   class ntp(
#     $server = $ntp::params::server
#   ) inherits ntp::params { }
#
# @example What you should have done
#   class ntp(
#     $server = 'UNSET'
#   ) {
#
#     include ntp::params
#
#     $server_real = $server ? {
#       'UNSET' => $::ntp::params::server,
#       default => $server,
#     }
#   }
#
# @enabled false
# @deprecated Puppet 2.6.x has been EOL for a long time now, so this check is
#   unnecessary.

PuppetLint.new_check(:class_inherits_from_params_class) do
  # Check the manifest tokens for any classes that inherit a params subclass
  # and record a warning for each instance found.
  def check
    class_indexes.each do |class_idx|
      next unless class_idx[:inherited_token] && class_idx[:inherited_token].value.end_with?('::params')

      notify(
        :warning,
        :message => 'class inheriting from params class',
        :line    => class_idx[:inherited_token].line,
        :column  => class_idx[:inherited_token].column
      )
    end
  end
end
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
