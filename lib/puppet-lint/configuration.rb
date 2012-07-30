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

    def method_missing(method, *args, &block)
      if method.to_s =~ /^(\w+)=$/
        option = $1
        add_option(option.to_s) if settings[option].nil?
        settings[option] = args[0]
      else
        nil
      end
    end

    def add_option(option)
      self.class.add_option(option)
    end

    def self.add_option(option)
      define_method("#{option}=") do |value|
        settings[option] = value
      end

      define_method(option) do
        settings[option]
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

    def self.ignore_paths
      settings[:ignore_paths] ||= []
    end

    def defaults
      settings.clear
      self.with_filename = false
      self.fail_on_warnings = false
      self.error_level = :all
      self.log_format = ''
    end
  end
end
