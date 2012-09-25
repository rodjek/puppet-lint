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

    def add_check(check, &b)
      self.class.add_check(check)
      check_method[check] = b
    end

    def settings
      @settings ||= {}
    end

    def check_method
      @check_method ||= {}
    end

    def checks
      check_method.keys
    end

    def defaults
      settings.clear
      self.with_filename = false
      self.fail_on_warnings = false
      self.error_level = :all
      self.log_format = ''
      self.with_context = false
    end
  end
end
