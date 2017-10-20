require 'yard'
require 'pry'

YARD::Tags::Library.define_tag("Enabled", :enabled)
YARD::Tags::Library.define_tag("Style Guide", :style_guide)

module YARD::CodeObjects
  module PuppetLint
    class Base < YARD::CodeObjects::NamespaceObject
      def self.new(*args)
        object = Object.class.instance_method(:new).bind(self).call(*args)
        existing = YARD::Registry.at(object.path)
        object = existing if existing && existing.class == self
        yield(object) if block_given?
        object
      end
    end

    class Group < YARD::CodeObjects::PuppetLint::Base
      def self.instance(key)
        instance = P(:root, key)
        return instance unless instance.is_a?(YARD::CodeObjects::Proxy)
        instance = self.new(:root, key)
        instance.visibility = :hidden
        P(:root).children << instance
        instance
      end

      def path
        @name.to_s
      end

      def type
        @name
      end
    end

    class Checks < Group
      def self.instance
        super(:puppet_lint_checks)
      end

      def name(_prefix = false)
        'puppet-lint checks'
      end
    end

    class Check < YARD::CodeObjects::PuppetLint::Base
      def initialize(name)
        super(YARD::CodeObjects::PuppetLint::Checks.instance, name)
      end

      def type
        :puppet_lint_check
      end
    end
  end
end

module YARD::Handlers
  module PuppetLint
    class CheckHandler < YARD::Handlers::Ruby::Base
      handles method_call(:new_check)

      def process
        return unless statement[0].type == :var_ref
        return unless statement[0].children.first.type == :const && statement[0].children.first.source == 'PuppetLint'
        check_name = statement[3].children.first.source

        object = YARD::CodeObjects::PuppetLint::Check.new(check_name.gsub(/\A:/, ''))
        object.source = statement[0]
        object.docstring = statement[0].docstring
        register object
      end
    end
  end
end
