# Resources
# http://docs.puppetlabs.com/guides/style_guide.html#resources

class PuppetLint::Plugins::CheckResources < PuppetLint::CheckPlugin
  def test(data)
    line_no = 0
    in_resource = true
    first_attribute = false
    data.split("\n").each do |line|
      line_no += 1

      if line.include? "{"
        in_resource = true
        first_attribute = true
        line = line.slice(line.index('{')..-1)
      end

      if in_resource
        # Resource titles SHOULD be quoted
        line.scan(/[^'"]\s*:/) do |match|
          unless line =~ /\$[\w:]+\s*:/
            warn "unquoted resource title on line #{line_no}"
          end
        end

        line.scan(/(\w+)\s*=>\s*([^\n,;]+)/) do |attr, value|
          # Ensure SHOULD be the first attribute listed
          if attr == 'ensure'
            unless first_attribute
              warn "ensure found on line #{line_no} but it's not the first attribute"
            end
          end

          # File modes SHOULD be represented as a 4 digits instead of 3, to
          # explicitly show that they are octal values.
          if attr == 'mode'
            unless value =~ /'\d{4}'/
              warn "mode should be represented as a 4 digit octal value on line #{line_no}"
            end
          end

          first_attribute = false
        end
        first_attribute = false
      end

      if line.include? "}"
        in_resource = false
      end
    end
  end
end
