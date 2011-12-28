class PuppetLint
  class Configuration
    def self.add_check(check)
      define_method("#{check}_enabled?") do
        settings["#{check}_disabled"] == true ? false : true
      end

      define_method("disable_#{check}") do
        settings["#{check}_disabled"] = true
      end

      define_method("enable_#{check}") do
        settings["#{check}_disabled"] = false
      end
    end

    def add_check(check)
      self.class.add_check(check)
    end

    def settings
      @settings ||= {}
    end

    def checks
      self.public_methods.select { |method|
        method =~ /^.+_enabled\?$/
      }.map { |method|
        method[0..-10]
      }
    end
  end
end
