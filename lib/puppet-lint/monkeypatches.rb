begin
  '%{test}' % { :test => 'replaced' } == 'replaced' # rubocop:disable Style/FormatString
rescue
  # monkeypatch String#% into Ruby 1.8.7
  class String
    Percent = instance_method('%') unless defined?(Percent)

    def %(*a, &b)
      a.flatten!

      string = case a.last
               when Hash
                 expand(a.pop)
               else
                 self
               end

      if a.empty?
        string
      else
        Percent.bind(string).call(a, &b)
      end
    end

    def expand!(vars = {})
      loop do
        changed = false
        vars.each do |var, value|
          var = var.to_s
          var.gsub!(%r{[^a-zA-Z0-9_]}, '')
          changed = gsub!(%r{\%\{#{var}\}}, value.to_s)
        end
        break unless changed
      end
      self
    end

    def expand(opts = {})
      dup.expand!(opts)
    end
  end
end

unless String.respond_to?(:prepend)
  # monkeypatch String#prepend into Ruby 1.8.7
  class String
    def prepend(lead)
      replace("#{lead}#{self}")
    end
  end
end
