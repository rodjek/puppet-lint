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

    # Public: Add an option to the PuppetLint::Configuration object from
    # outside the class.
    #
    # option - The String name of the option.
    #
    # Returns nothing.
    #
    # Signature
    #
    #   <option>
    #   <option>=(value)
    def self.add_option(option)
      # Public: Set the value of the named option.
      #
      # value - The value to set the option to.
      #
      # Returns nothing.
      define_method("#{option}=") do |value|
        settings[option] = value
      end

      # Public: Get the value of the named option.
      #
      # Returns the value of the option.
      define_method(option) do
        settings[option]
      end
    end

    # Internal: Register a new check.
    #
    # check - The String name of the check
    # b     - The Block containing the logic of the check
    #
    # Returns nothing.
    def add_check(check, &b)
      self.class.add_check(check)
      check_method[check] = b
    end

    # Internal: Register a new check helper method.
    #
    # name - The String name of the method.
    # b    - The Block containing the logic of the helper.
    #
    # Returns nothing.
    def add_helper(name, &b)
      helper_method[name] = b
    end

    # Internal: Access the internal storage for settings.
    #
    # Returns a Hash containing all the settings.
    def settings
      @settings ||= {}
    end

    # Internal: Access the internal storage for check method blocks.
    #
    # Returns a Hash containing all the check blocks.
    def check_method
      @check_method ||= {}
    end

    # Public: Get a list of all the defined checks.
    #
    # Returns an Array of String check names.
    def checks
      check_method.keys
    end

    # Internal: Access the internal storage for helper method blocks.
    #
    # Returns a Hash containing all the helper blocks.
    def helper_method
      @helper_method ||= {}
    end

    # Public: Get a list of all the helper methods.
    #
    # Returns an Array of String method names.
    def helpers
      helper_method.keys
    end

    # Public: Clear the PuppetLint::Configuration storage and set some sane
    # default values.
    #
    # Returns nothing.
    def defaults
      settings.clear
      self.with_filename = false
      self.fail_on_warnings = false
      self.error_level = :all
      self.log_format = ''
      self.with_context = false
      self.fix = false
    end
  end
end
