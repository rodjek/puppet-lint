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

unless String.respond_to?('prepend')
  class String
    def prepend(lead)
      self.replace "#{lead}#{self}"
    end
  end
end

class PuppetLint::NoCodeError < StandardError; end

class PuppetLint
  VERSION = '0.1.8'

  attr_reader :code, :file, :show_filename

  def initialize(options)
    @data = nil
    @errors = 0
    @warnings = 0
    @show_filename = 0
    @path = ''
    @error_level = options[:error_level]
  end

  def file=(path)
    if File.exist? path
      @path = File.expand_path(path)
      @data = File.read(path)
    end
  end

  def code=(value)
    @data = value
  end

  def show_filename=(value)
    @show_filename = value
  end

  def report(kind, message)
    #msg = message
    if kind == :warnings
      @warnings += 1
      message.prepend('WARNING: ')
    else
      @errors += 1
      message.prepend('ERROR: ')
    end
    if @show_filename
      message.prepend("#{@path} - ")
    end
    puts message
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
      problems = plugin.new.run(@path, @data)
      case @error_level
      when :warning
        problems[:warnings].each { |warning| report :warnings, warning }
      when :error
        problems[:errors].each { |error| report :errors, error }
      else
        problems[:warnings].each { |warning| report :warnings, warning }
        problems[:errors].each { |error| report :errors, error }
      end
    end
  end
end

