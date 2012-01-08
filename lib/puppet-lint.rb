# We're doing this instead of a gem dependency so folks using Puppet
# from their distro packages don't have to install the gem.
begin
  require 'puppet'
rescue LoadError
  puts 'Unable to require puppet.  Please gem install puppet and try again.'
  exit 1
end

require 'puppet-lint/configuration'
require 'puppet-lint/plugin'

unless String.respond_to?('prepend')
  class String
    def prepend(lead)
      self.replace "#{lead}#{self}"
    end
  end
end

# If we are using an older ruby version, we back-port the basic functionality
# we need for formatting output: 'somestring' % <hash>
begin
  if ('%{test}' % {:test => 'replaced'} == 'replaced')
    # If this works, we are all good to go.
  end
rescue
  # If the test failed (threw a error), monkeypatch String.
  # Most of this code came from http://www.ruby-forum.com/topic/144310 but was
  # simplified for our use.

  # Basic implementation of 'string' % { } like we need it. needs work.
  class String
    Percent = instance_method '%' unless defined? Percent
    def % *a, &b
      a.flatten!

      string = case a.last
      when Hash
        expand a.pop
      else
        self
      end

      if a.empty?
        string
      else
        Percent.bind(string).call(*a, &b)
      end

    end
    def expand! vars = {}
      loop do
        changed = false
        vars.each do |var, value|
          var = var.to_s
          var.gsub! %r/[^a-zA-Z0-9_]/, ''
          [
            %r/\%\{#{ var }\}/,
          ].each do |pat|
            changed = gsub! pat, "#{ value }"
          end
        end
        break unless changed
      end
      self
    end
    def expand opts = {}
      dup.expand! opts
    end
  end
end

class PuppetLint::NoCodeError < StandardError; end

class PuppetLint
  VERSION = '0.1.9'

  attr_reader :code, :file

  def initialize
    @data = nil
    @errors = 0
    @warnings = 0
    @path = ''
  end

  def self.configuration
    @configuration ||= PuppetLint::Configuration.new
  end

  def configuration
    self.class.configuration
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

  def log_format
    if configuration.log_format == ''
      ## recreate previous old log format as far as thats possible.
      format = '%{KIND}: %{message} on line %{linenumber}'
      if configuration.with_filename
        format.prepend '%{path} - '
      end
      configuration.log_format = format
    end
    return configuration.log_format
  end

  def format_message(message)
    format = log_format
    puts format % message
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
    if configuration.with_filename
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

  def checks
    PuppetLint::CheckPlugin.repository.map do |plugin|
      plugin.new.checks
    end.flatten
  end

  def run
    if @data.nil?
      raise PuppetLint::NoCodeError
    end

    PuppetLint::CheckPlugin.repository.each do |plugin|
      problems = plugin.new.run(@path, @data)
      case configuration.error_level
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

# Default configuration options
PuppetLint.configuration.fail_on_warnings = false
PuppetLint.configuration.error_level = :all
PuppetLint.configuration.with_filename = false
PuppetLint.configuration.log_format = ''

require 'puppet-lint/plugins'
