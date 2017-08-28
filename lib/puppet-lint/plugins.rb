require 'pathname'

class PuppetLint
  # Public: Various methods that implement puppet-lint's plugin system
  #
  # Examples
  #
  #   PuppetLint::Plugins.load_spec_helper
  class Plugins
    # Internal: Find any gems containing puppet-lint plugins and load them.
    #
    # Returns nothing.
    def self.load_from_gems
      gem_directories.select { |path|
        (path + 'puppet-lint/plugins').directory?
      }.each do |gem_path|
        Dir["#{gem_path + 'puppet-lint/plugins'}/*.rb"].each do |file|
          load(file)
        end
      end
    end

    # Public: Load the puppet-lint spec_helper.rb
    #
    # Returns nothings.
    def self.load_spec_helper
      gemspec = gemspecs.select { |spec| spec.name == 'puppet-lint' }.first
      load(Pathname.new(gemspec.full_gem_path) + 'spec/spec_helper.rb')
    end

    class << self
      private

      # Internal: Check if RubyGems is loaded and available.
      #
      # Returns true if RubyGems is available, false if not.
      def rubygems?
        defined?(::Gem)
      end

      # Internal: Retrieve a list of avaliable gemspecs.
      #
      # Returns an Array of Gem::Specification objects.
      def gemspecs
        @gemspecs ||= if Gem::Specification.respond_to?(:latest_specs)
                        Gem::Specification.latest_specs(load_prerelease_plugins?)
                      else
                        Gem.searcher.init_gemspecs
                      end
      end

      # Internal: Determine whether to load plugins that contain a letter in their version number.
      #
      # Returns true if the configuration is set to load "prerelease" gems, false otherwise.
      def load_prerelease_plugins?
        # Load prerelease plugins (which ruby defines as any gem which has a letter in its version number).
        # Can't use puppet-lint configuration object here because this code executes before the command line is parsed.
        if ENV['PUPPET_LINT_LOAD_PRERELEASE_PLUGINS']
          return %w[true yes].include?(ENV['PUPPET_LINT_LOAD_PRERELEASE_PLUGINS'].downcase)
        end
        false
      end

      # Internal: Retrieve a list of available gem paths from RubyGems.
      #
      # Returns an Array of Pathname objects.
      def gem_directories
        if rubygems?
          gemspecs.reject { |spec| spec.name == 'puppet-lint' }.map do |spec|
            Pathname.new(spec.full_gem_path) + 'lib'
          end
        else
          []
        end
      end
    end
  end
end

Dir[File.expand_path('plugins/**/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

PuppetLint::Plugins.load_from_gems
