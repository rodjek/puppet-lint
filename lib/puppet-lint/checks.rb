require 'puppet-lint/checkplugin'

class PuppetLint::Checks
  # Public: Get an Array of problem Hashes.
  attr_accessor :problems

  # Public: Initialise a new PuppetLint::Checks object.
  def initialize
    @problems = []
  end

  # Internal: Tokenise the manifest code and prepare it for checking.
  #
  # fileinfo - A Hash containing the following:
  #   :fullpath - The expanded path to the file as a String.
  #   :filename - The name of the file as a String.
  #   :path     - The original path to the file as passed to puppet-lint as
  #               a String.
  # data     - The String manifest code to be checked.
  #
  # Returns nothing.
  def load_data(fileinfo, data)
    lexer = PuppetLint::Lexer.new
    begin
      PuppetLint::Data.tokens = lexer.tokenise(data)
    rescue PuppetLint::LexerError => e
      problems << {
        :kind       => :error,
        :check      => :syntax,
        :message    => 'Syntax error (try running `puppet parser validate <file>`)',
        :linenumber => e.line_no,
        :column     => e.column,
      }
      PuppetLint::Data.tokens = []
    end
    PuppetLint::Data.fullpath = fileinfo[:fullpath]
    PuppetLint::Data.manifest_lines = data.split("\n")
    @fileinfo = fileinfo
    @data = data
  end

  # Internal: Run the lint checks over the manifest code.
  #
  # fileinfo - A Hash containing the following:
  #   :fullpath - The expanded path to the file as a String.
  #   :filename - The name of the file as a String.
  #   :path     - The original path to the file as passed to puppet-lint as
  #               a String.
  # data     - The String manifest code to be checked.
  #
  # Returns an Array of problem Hashes.
  def run(fileinfo, data)
    load_data(fileinfo, data)

    enabled_checks.each do |check|
      klass = PuppetLint.configuration.check_object[check].new
      @problems.concat(klass.run)
    end

    @problems
  end

  # Internal: Get a list of checks that have not been disabled.
  #
  # Returns an Array of String check names.
  def enabled_checks
    @enabled_checks ||= Proc.new do
      PuppetLint.configuration.checks.select { |check|
        PuppetLint.configuration.send("#{check}_enabled?")
      }
    end.call
  end

  def manifest
    PuppetLint::Data.tokens.map { |t| t.to_manifest }.join('')
  end
end
