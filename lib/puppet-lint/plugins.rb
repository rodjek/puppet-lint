require 'pathname'

class PuppetLint
  class Plugins
    # Public: Find any gems containing puppet-lint plugins and load them.
    #
    # Returns nothing.
    def self.load_from_gems
      gem_directories.select { |path|
        (path + 'puppet-lint/plugins').directory?
      }.each do |gem_path|
        Dir["#{(gem_path + 'puppet-lint/plugins').to_s}/*.rb"].each do |file|
          load file
        end
      end
    end
  private
    # Internal: Check if RubyGems is loaded and available.
    #
    # Returns true if RubyGems is available, false if not.
    def self.has_rubygems?
      defined? ::Gem
    end

    # Internal: Retrieve a list of available gem paths from RubyGems.
    #
    # Returns an Array of Pathname objects.
    def self.gem_directories
      if has_rubygems?
        if Gem::Specification.respond_to? :latest_specs
          Gem::Specification.latest_specs.map do |spec|
            Pathname.new(spec.full_gem_path) + 'lib'
          end
        else
          Gem.searcher.init_gemspecs.map do |spec|
            Pathname.new(spec.full_gem_path) + 'lib'
          end
        end
      else
        []
      end
    end
  end
end

require 'puppet-lint/plugins/check_classes'
require 'puppet-lint/plugins/check_comments'
require 'puppet-lint/plugins/check_conditionals'
require 'puppet-lint/plugins/check_documentation'
require 'puppet-lint/plugins/check_strings'
require 'puppet-lint/plugins/check_variables'
require 'puppet-lint/plugins/check_whitespace'
require 'puppet-lint/plugins/check_resources'

PuppetLint::Plugins.load_from_gems
