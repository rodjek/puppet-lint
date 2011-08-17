# Resources
# http://docs.puppetlabs.com/guides/style_guide.html#resources

class PuppetLint::Plugins::CheckResources < PuppetLint::CheckPlugin
  def test(data)
    line_no = 0
    in_resource = true
    data.split("\n").each do |line|
      line_no += 1

      if line.include? "{"
        in_resource = true
        line = line.slice(line.index('{')..-1)
      end

      if in_resource
        # Resource titles SHOULD be quoted
        line.scan(/[^'"]\s*:/) do |match|
          unless line =~ /\$\w+\s*:/
            warn "unquoted resource title on line #{line_no}"
          end
        end
      end

      if line.include? "}"
        in_resource = false
      end
    end
  end
end
