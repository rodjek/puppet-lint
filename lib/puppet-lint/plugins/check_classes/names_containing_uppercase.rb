# Public: Find and warn about module names with illegal uppercase characters.
#
# https://puppet.com/docs/puppet/latest/modules_fundamentals.html#allowed-module-names
# Provides a fix. [puppet-lint #554]
PuppetLint.new_check(:names_containing_uppercase) do
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
