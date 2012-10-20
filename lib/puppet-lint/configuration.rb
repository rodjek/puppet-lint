class PuppetLint
  class Configuration
    # Internal: Add helper methods for a new check to the
    # PuppetLint::Configuration object.
    #
    # check - The String name of the check.
    #
    # Returns nothing.
    #
    # Signature
    #
    #   <check>_enabled?
    #   disable_<check>
    #   enable_<check>
    def self.add_check(check)
      # Public: Determine if the named check is enabled.
      #
      # Returns true if the check is enabled, otherwise return false.
      define_method("#{check}_enabled?") do
        settings["#{check}_disabled"] == true ? false : true
      end

      # Public: Disable the named check.
      #
      # Returns nothing.
      define_method("disable_#{check}") do
        settings["#{check}_disabled"] = true
      end

      # Public: Enable the named check.
      #
      # Returns nothing.
      define_method("enable_#{check}") do
        settings["#{check}_disabled"] = false
      end
    end

    # Public: Catch situations where options are being set for the first time
    # and create the necessary methods to get & set the option in the future.
    #
    # args[0] - The value to set the option to.
    #
    # Returns nothing.
    #
    # Signature
    #
    #   <option>=(value)
    def method_missing(method, *args, &block)
      if method.to_s =~ /^(\w+)=$/
        option = $1
        add_option(option.to_s) if settings[option].nil?
        settings[option] = args[0]
      else
        nil
      end
    end

    # Internal: Add options to the PuppetLint::Configuration object from inside
    # the class.
    #
    # option - The String name of the option.
    #
    # Returns nothing.
    #
    # Signature
    #
    #   <option>
    #   <option>=(value)
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
