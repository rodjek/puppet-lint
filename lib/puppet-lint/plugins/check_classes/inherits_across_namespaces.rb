# Inheritance may be used within a module, but must not be used across module
# namespaces. Cross-module dependencies should be satisfied in a more portable
# way that does not violate the concept of modularity, such as with `include`
# statements or relationship declarations.
#
# @example What you have done
#   class ssh inherits server { }
#
#   class ssh::client inherits workstation { }
#
#   class wordpress inherits apache { }
#
# @example What you should have done
#   class ssh { }
#
#   class ssh::client inherits ssh { }
#
#   class ssh::server inherits ssh { }
#
#   class ssh::server::solaris inherits ssh::server { }
#
# @style_guide #class-inheritance
# @enabled true
PuppetLint.new_check(:inherits_across_namespaces) do
  # Test the manifest tokens for any classes that inherit across namespaces and
  # record a warning for each instance found.
  def check
    class_indexes.each do |class_idx|
      next if class_idx[:inherited_token].nil?

      inherited_module_name = class_idx[:inherited_token].value.split('::').reject(&:empty?).first
      class_module_name = class_idx[:name_token].value.split('::').reject(&:empty?).first

      next if class_module_name == inherited_module_name

      notify(
        :warning,
        :message => 'class inherits across module namespaces',
        :line    => class_idx[:inherited_token].line,
        :column  => class_idx[:inherited_token].column
      )
    end
  end
end
