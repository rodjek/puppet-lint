# Module, class and defined type names should not contain uppercase characters.
#
# @example What you have done
#   class SSH { }
#
# @example What you should have done
#   class ssh { }
#
# @style_guide https://docs.puppet.com/puppet/latest/reference/modules_fundamentals.html#allowed-module-names
# @enabled true
PuppetLint.new_check(:names_containing_uppercase) do
  # Find and warn about module names with illegal uppercase characters.
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      next unless class_idx[:name_token].value =~ %r{[A-Z]}

      obj_type = if class_idx[:type] == :CLASS
                   'class'
                 else
                   'defined type'
                 end

      notify(
        :error,
        :message => "#{obj_type} '#{class_idx[:name_token].value}' contains illegal uppercase",
        :line    => class_idx[:name_token].line,
        :column  => class_idx[:name_token].column,
        :token   => class_idx[:name_token]
      )
    end
  end

  def fix(problem)
    problem[:token].value.downcase!
  end
end
