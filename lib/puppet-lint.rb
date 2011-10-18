# We're doing this instead of a gem dependency so folks using Puppet
# from their distro packages don't have to install the gem.
begin
  require 'puppet'
rescue LoadError
  puts 'Unable to require puppet.  Please gem install puppet and try again.'
  exit 1
end

require 'puppet-lint/plugin'
require 'puppet-lint/plugins'

class PuppetLint::NoCodeError < StandardError; end

class PuppetLint
  VERSION = '0.1.7'

  attr_reader :code, :file

  def initialize
    @data = nil
    @errors = 0
    @warnings = 0
  end

  def file=(path)
    if File.exist? path
      @data = File.read(path)
    end
  end

  def code=(value)
    @data = value
  end

  def report(kind, message)
    if kind == :warnings
      @warnings += 1
      puts "WARNING: #{message}"
    else
      @errors += 1
      puts "ERROR: #{message}"
    end
  end

  def errors?
    @errors != 0
  end

  def warnings?
    @warnings != 0
  end

  def run
    if @data.nil?
      raise PuppetLint::NoCodeError
    end

    PuppetLint::CheckPlugin.repository.each do |plugin|
      problems = plugin.new.run(@data)
      problems[:errors].each { |error| report :errors, error }
      problems[:warnings].each { |warning| report :warnings, warning }
    end
  end
end

