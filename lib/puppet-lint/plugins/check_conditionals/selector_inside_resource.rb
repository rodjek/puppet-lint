# You should not intermingle conditionals with resource declarations. When
# using conditionals for data assignment, you should separate conditional code
# from the resource declarations.
#
# @example What you have done
#   file { '/tmp/readme.txt':
#     mode => $::operatingsystem ? {
#       debian => '0777',
#       redhat => '0776',
#       fedora => '0007',
#     }
#   }
#
# @example What you should have done
#   $file_mode = $::operatingsystem ? {
#     debian => '0777',
#     redhat => '0776',
#     fedora => '0007',
#   }
#
#   file { '/tmp/readme.txt':
#     mode => $file_mode,
#   }
#
# @style_guide #keep-resource-declarations-simple
# @enabled true
PuppetLint.new_check(:selector_inside_resource) do
  # Test the manifest tokens for any selectors embedded within resource
  # declarations and record a warning for each instance found.
  def check
    resource_indexes.each do |resource|
      resource[:tokens].each do |token|
        next unless token.type == :FARROW && token.next_code_token.type == :VARIABLE
        next if token.next_code_token.next_code_token.nil?
        next unless token.next_code_token.next_code_token.type == :QMARK

        notify(
          :warning,
          :message => 'selector inside resource block',
          :line    => token.line,
          :column  => token.column
        )
      end
    end
  end
end
