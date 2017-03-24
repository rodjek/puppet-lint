# Public: Test the manifest tokens for any classes that inherit across
# namespaces and record a warning for each instance found.
#
# https://docs.puppet.com/guides/style_guide.html#class-inheritance
PuppetLint.new_check(:inherits_across_namespaces) do
  def check
    class_indexes.each do |class_idx|
      unless class_idx[:inherited_token].nil?
        inherited_module_name = class_idx[:inherited_token].value.split('::').reject { |r| r.empty? }.first
        class_module_name = class_idx[:name_token].value.split('::').reject { |r| r.empty? }.first

        unless class_module_name == inherited_module_name
          notify :warning, {
            :message => "class inherits across module namespaces",
            :line    => class_idx[:inherited_token].line,
            :column  => class_idx[:inherited_token].column,
          }
        end
      end
    end
  end
end
