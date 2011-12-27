class PuppetLint
  module Plugin
    module ClassMethods
      def repository
        @repository ||= []
      end

      def inherited(klass)
        repository << klass
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end

class PuppetLint::CheckPlugin
  include PuppetLint::Plugin
  attr_reader :warnings, :errors

  def initialize
    @warnings = []
    @errors = []
  end

  def warn(message)
    @warnings << message
  end

  def error(message)
    @errors << message
  end

  def run(path, data)
    test(path, data)

    {:warnings => @warnings, :errors => @errors}
  end

  def test(data)
    raise NotImplementedError.new "Oh no"
  end
end

