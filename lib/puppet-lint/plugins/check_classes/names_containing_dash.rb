# Public: Check the manifest tokens for any classes or defined types that
# have a dash in their name and record an error for each instance found.
#
# No style guide reference
PuppetLint.new_check(:names_containing_dash) do
  def check
    (class_indexes + defined_type_indexes).each do |class_idx|
      if class_idx[:name_token].value.include? '-'
        if class_idx[:type] == :CLASS
          obj_type = 'class'
        else
          obj_type = 'defined type'
        end

        notify :error, {
          :message => "#{obj_type} name containing a dash",
          :line    => class_idx[:name_token].line,
          :column  => class_idx[:name_token].column,
        }
      end
    end
  end
end
