# rubocop:disable Naming/FileName

require 'puppet-lint'
require 'puppet-lint/optparser'
require 'rake'
require 'rake/tasklib'
require 'puppet-lint/report/codeclimate'

# Public: A Rake task that can be loaded and used with everything you need.
#
# Examples
#
#   require 'puppet-lint'
#   PuppetLint::RakeTask.new
class PuppetLint::RakeTask < Rake::TaskLib
  include ::Rake::DSL if defined?(::Rake::DSL)

  DEFAULT_PATTERN = '**/*.pp'.freeze

  attr_accessor :name, :pattern, :ignore_paths, :with_filename, :disable_checks, :only_checks, :fail_on_warnings, :error_level, :log_format, :with_context, :fix, :show_ignored, :relative

  # Public: Initialise a new PuppetLint::RakeTask.
  #
  # args - Not used.
  #
  # Example
  #
  #   PuppetLint::RakeTask.new
  # rubocop:disable Lint/MissingSuper
  def initialize(*args, &task_block)
    @name = args.shift || :lint
    @pattern = DEFAULT_PATTERN
    @with_filename = true
    @disable_checks = []
    @only_checks = []
    @ignore_paths = []

    define(args, &task_block)
  end

  def define(args, &task_block)
    desc 'Run puppet-lint'

    yield(*[self, args].slice(0, task_block.arity)) if task_block

    # clear any (auto-)pre-existing task
    Rake::Task[@name].clear if Rake::Task.task_defined?(@name)
    task @name do
      PuppetLint::OptParser.build

      if Array(@only_checks).any?
        enable_checks = Array(@only_checks).map(&:to_sym)
        PuppetLint.configuration.checks.each do |check|
          if enable_checks.include?(check)
            PuppetLint.configuration.send("enable_#{check}")
          else
            PuppetLint.configuration.send("disable_#{check}")
          end
        end
      end

      Array(@disable_checks).each do |check|
        PuppetLint.configuration.send("disable_#{check}")
      end

      ['with_filename', 'fail_on_warnings', 'error_level', 'log_format', 'with_context', 'fix', 'show_ignored', 'relative'].each do |config|
        value = instance_variable_get("@#{config}")
        PuppetLint.configuration.send("#{config}=".to_sym, value) unless value.nil?
      end

      if PuppetLint.configuration.ignore_paths && @ignore_paths.empty?
        @ignore_paths = PuppetLint.configuration.ignore_paths
      end

      if PuppetLint.configuration.pattern
        @pattern = PuppetLint.configuration.pattern
      end

      RakeFileUtils.send(:verbose, true) do
        linter = PuppetLint.new
        matched_files = FileList[@pattern]
        all_problems = []

        matched_files = matched_files.exclude(*@ignore_paths)

        matched_files.to_a.each do |puppet_file|
          next unless File.file?(puppet_file)

          linter.file = puppet_file
          linter.run
          all_problems << linter.print_problems

          if PuppetLint.configuration.fix && linter.problems.none? { |e| e[:check] == :syntax }
            File.write(puppet_file, linter.manifest)
          end
        end

        if PuppetLint.configuration.codeclimate_report_file
          PuppetLint::Report::CodeClimateReporter.write_report_file(all_problems, PuppetLint.configuration.codeclimate_report_file)
        end

        abort if linter.errors? || (
          linter.warnings? && PuppetLint.configuration.fail_on_warnings
        )
      end
    end
  end
end

PuppetLint::RakeTask.new
