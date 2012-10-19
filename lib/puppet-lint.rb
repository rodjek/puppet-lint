require 'puppet-lint/version'
require 'puppet-lint/lexer'
require 'puppet-lint/configuration'
require 'puppet-lint/plugin'
require 'puppet-lint/bin'

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
        Percent.bind(string).call(a, &b)
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
  attr_reader :data

  def initialize
    @data = nil
    @statistics = {:error => 0, :warning => 0}
    @fileinfo = {:path => ''}
  end

  def self.configuration
    @configuration ||= PuppetLint::Configuration.new
  end

  def configuration
    self.class.configuration
  end

  def file=(path)
    if File.exist? path
      @fileinfo[:path] = path
      @fileinfo[:fullpath] = File.expand_path(path)
      @fileinfo[:filename] = File.basename(path)
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

  def print_context(message, linter)
    # XXX: I don't really like the way this has been implemented (passing the
    # linter object down through layers of functions.  Refactor me!
    return if message[:check] == 'documentation'
    line = linter.manifest_lines[message[:linenumber] - 1]
    offset = line.index(/\S/)
    puts "\n  #{line.strip}"
    printf "%#{message[:column] + 2 - offset}s\n\n", '^'
  end

  def report(problems, linter)
    problems.each do |message|
      @statistics[message[:kind]] += 1
      ## Add some default attributes.
      message.merge!(@fileinfo) {|key, v1, v2| v1 }
      message[:KIND] = message[:kind].to_s.upcase

      if configuration.error_level == message[:kind] or configuration.error_level == :all
        format_message message
        print_context(message, linter) if configuration.with_context
      end
    end
  end

  def errors?
    @statistics[:error] != 0
  end

  def warnings?
    @statistics[:warning] != 0
  end

  def run
    if @data.nil?
      raise PuppetLint::NoCodeError
    end

    linter = PuppetLint::Checks.new
    problems = linter.run(@fileinfo, @data)
    report problems, linter
  end
end

# Default configuration options
PuppetLint.configuration.defaults

require 'puppet-lint/plugins'
