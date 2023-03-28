# rubocop:disable Naming/FileName

# encoding: utf-8

require 'set'
require 'json'
require 'puppet-lint/version'
require 'puppet-lint/lexer'
require 'puppet-lint/configuration'
require 'puppet-lint/data'
require 'puppet-lint/checks'
require 'puppet-lint/report/github'
require 'puppet-lint/bin'
require 'puppet-lint/monkeypatches'

class PuppetLint::NoCodeError < StandardError; end

class PuppetLint::NoFix < StandardError; end

# Parser Syntax Errors
class PuppetLint::SyntaxError < StandardError
  attr_reader :token

  def initialize(token)
    @token = token
    super
  end
end

# Public: The public interface to puppet-lint.
class PuppetLint
  # Public: Gets/Sets the String manifest code to be checked.
  attr_accessor :code

  # Public: Gets the String manifest with the errors fixed.
  attr_reader :manifest

  # Public: Returns an Array of Hashes describing the problems found in the
  # manifest.
  #
  # Each Hash will contain *at least*:
  #   :check   - The Symbol name of the check that generated the problem.
  #   :kind    - The Symbol kind of the problem (:error, :warning, or
  #              :fixed).
  #   :line    - The Integer line number of the location of the problem in
  #              the manifest.
  #   :column  - The Integer column number of the location of the problem in
  #              the manifest.
  #   :message - The String message describing the problem that was found.
  attr_reader :problems

  # Public: Gets/Sets the String path to the manifest to be checked.
  attr_accessor :path

  # Public: Returns a Hash of linter statistics
  #
  #   :error   - An Integer count of errors found in the manifest.
  #   :warning - An Integer count of warnings found in the manifest.
  #   :fixed   - An Integer count of problems found in the manifest that were
  #              automatically fixed.
  attr_reader :statistics

  # Public: Initialise a new PuppetLint object.
  def initialize
    @code = nil
    @statistics = { error: 0, warning: 0, fixed: 0, ignored: 0 }
    @manifest = ''
  end

  # Public: Access PuppetLint's configuration from outside the class.
  #
  # Returns a PuppetLint::Configuration object.
  def self.configuration
    @configuration ||= PuppetLint::Configuration.new
  end

  # Public: Access PuppetLint's configuration from inside the class.
  #
  # Returns a PuppetLint::Configuration object.
  def configuration
    self.class.configuration
  end

  # Public: Set the path of the manifest file to be tested and read the
  # contents of the file.
  #
  # Returns nothing.
  def file=(path)
    return unless File.exist?(path)

    @path = path
    File.open(path, 'rb:UTF-8') do |f|
      @code = f.read
    end

    # Check if the input is an SE Linux policy package file (which also use
    # the .pp extension), which all have the first 4 bytes 0xf97cff8f.
    @code = '' if @code[0..3].unpack('V').first == 0xf97cff8f
  end

  # Internal: Retrieve the format string to be used when writing problems to
  # STDOUT.  If the user has not specified a custom log format, build one for
  # them.
  #
  # Returns a format String to be used with String#%.
  def log_format
    if configuration.log_format.nil? || configuration.log_format.empty?
      format = '%{KIND}: %{message} on line %{line}'
      format.prepend('%{path} - ') if configuration.with_filename
      format.concat(' (check: %{check})')
      configuration.log_format = format
    end

    configuration.log_format
  end

  # Internal: Format a problem message and print it to STDOUT.
  #
  # message - A Hash containing all the information about a problem.
  #
  # Returns nothing.
  def format_message(message)
    format = log_format
    puts format % message

    puts "  #{message[:reason]}" if message[:kind] == :ignored && !message[:reason].nil?
    print_context(message)
  end

  # Internal: Format a problem message and print it to STDOUT so GitHub Actions
  # recognizes it as an annotation.
  #
  # message - A Hash containing all the information about a problem.
  #
  # Returns nothing.
  def print_github_annotation(message)
    puts PuppetLint::Report::GitHubActionsReporter.format_problem(path, message)
  end

  # Internal: Get the line of the manifest on which the problem was found
  #
  # message - A Hash containing all the information about a problem.
  #
  # Returns the problematic line as a string.
  def get_context(message)
    PuppetLint::Data.manifest_lines[message[:line] - 1].strip
  end

  # Internal: Print out the line of the manifest on which the problem was found
  # as well as a marker pointing to the location on the line.
  #
  # message - A Hash containing all the information about a problem.
  #
  # Returns nothing.
  def print_context(message)
    return if message[:check] == 'documentation'
    return if message[:kind] == :fixed
    line = message[:context]
    return unless line
    offset = line.index(%r{\S}) || 1
    puts "\n  #{line.strip}"
    printf("%#{message[:column] + 2 - offset}s\n\n", '^')
  end

  # Internal: Print the reported problems with a manifest to stdout.
  #
  # problems - An Array of problem Hashes as returned by
  #            PuppetLint::Checks#run.
  #
  # Returns array of problem.
  def report(problems)
    json = []
    print_stdout = !(configuration.json || configuration.sarif)

    problems.each do |message|
      next if message[:kind] == :ignored && !PuppetLint.configuration.show_ignored

      message[:KIND] = message[:kind].to_s.upcase

      next unless message[:kind] == :fixed || [message[:kind], :all].include?(configuration.error_level)

      message[:context] = get_context(message) if configuration.with_context

      json << message

      if print_stdout
        format_message(message)
        print_github_annotation(message) if configuration.github_actions
      end
    end
    $stderr.puts 'Try running `puppet parser validate <file>`' if problems.any? { |p| p[:check] == :syntax }
    json
  end

  # Public: Determine if PuppetLint found any errors in the manifest.
  #
  # Returns true if errors were found, otherwise returns false.
  def errors?
    @statistics[:error] != 0
  end

  # Public: Determine if PuppetLint found any warnings in the manifest.
  #
  # Returns true if warnings were found, otherwise returns false.
  def warnings?
    @statistics[:warning] != 0
  end

  # Public: Run the loaded manifest code through the lint checks and print the
  # results of the checks to stdout.
  #
  # Returns nothing.
  # Raises PuppetLint::NoCodeError if no manifest code has been loaded.
  def run
    raise PuppetLint::NoCodeError if @code.nil?

    if @code.empty?
      @problems = []
      @manifest = ''
      return
    end

    linter = PuppetLint::Checks.new
    @problems = linter.run(@path, @code)
    @problems.each { |problem| @statistics[problem[:kind]] += 1 }

    @manifest = linter.manifest if PuppetLint.configuration.fix
  end

  # Public: Print any problems that were found out to stdout.
  #
  # Returns an array of problems.
  def print_problems
    report(@problems)
  end

  # Public: Define a new check.
  #
  # name  - A unique name for the check as a Symbol.
  # block - The check logic. This must contain a `check` method and optionally
  #         a `fix` method.
  #
  # Returns nothing.
  #
  # Examples
  #
  #   PuppetLint.new_check(:foo) do
  #     def check
  #     end
  #   end
  def self.new_check(name, &block)
    class_name = name.to_s.split('_').map(&:capitalize).join
    klass = PuppetLint.const_set("Check#{class_name}", Class.new(PuppetLint::CheckPlugin))
    klass.const_set(:NAME, name)
    klass.class_exec(&block)
    PuppetLint.configuration.add_check(name, klass)
    PuppetLint::Data.ignore_overrides[name] ||= {}
  end
end

# Default configuration options
PuppetLint.configuration.defaults

require 'puppet-lint/plugins'
