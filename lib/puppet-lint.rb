require 'puppet-lint/plugin'
require 'puppet-lint/plugins'

class PuppetLint
  VERSION = '0.0.1'

  attr_reader :code, :file

  def initialize
    @data = nil
  end

  def file=(path)
    if File.exist? path
      @data = File.read(path)
    end
  end

  def code=(value)
    @data = value
  end

  def run
    PuppetLint::CheckPlugin.repository.each do |plugin|
      problems = plugin.new.run(@data)
      problems[:errors].each { |error| puts "ERROR: #{error}" }
      problems[:warnings].each { |warning| puts "WARNING: #{warning}" }
    end
  end
end
