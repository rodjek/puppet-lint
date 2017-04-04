# Public: Check the manifest tokens for any classes that inherit a params
# subclass and record a warning for each instance found.
#
# No style guide reference
PuppetLint.new_check(:class_inherits_from_params_class) do
  def check
    class_indexes.each do |class_idx|
      unless class_idx[:inherited_token].nil?
        if class_idx[:inherited_token].value.end_with? '::params'
          notify :warning, {
            :message => 'class inheriting from params class',
            :line    => class_idx[:inherited_token].line,
            :column  => class_idx[:inherited_token].column,
          }
        end
      end
    end
  end
end
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
