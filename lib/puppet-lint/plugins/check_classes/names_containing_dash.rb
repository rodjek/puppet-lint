# Support for dashes in class and defined type names differs depending on the
# release of Puppet you're running. To ensure compatibility on all versions,
# you should avoid using dashes.
#
# @example What you have done
#   class foo::bar-baz {}
#
# @example What you should have done
#   class foo::bar_baz {}
#
# @enabled true
PuppetLint.new_check(:names_containing_dash) do
  # Check the manifest tokens for any classes or defined types that have a dash
  # in their name and record an error for each instance found.
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      next unless class_idx[:name_token].value.include?('-')

      obj_type = if class_idx[:type] == :CLASS
                   'class'
                 else
                   'defined type'
                 end

      notify(
        :error,
        :message => "#{obj_type} name containing a dash",
        :line    => class_idx[:name_token].line,
        :column  => class_idx[:name_token].column
      )
    end
  end
end
