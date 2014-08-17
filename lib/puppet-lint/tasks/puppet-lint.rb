require 'puppet-lint'
require 'puppet-lint/optparser'
require 'rake'
require 'rake/tasklib'

class PuppetLint
  # Public: A Rake task that can be loaded and used with everything you need.
  #
  # Examples
  #
  #   require 'puppet-lint'
  #   PuppetLint::RakeTask.new
  class RakeTask < ::Rake::TaskLib
    # Public: Initialise a new PuppetLint::RakeTask.
    #
    # args - Not used.
    def initialize(*args)
      desc 'Run puppet-lint'

      task :lint do
        PuppetLint.configuration.with_filename = true
        PuppetLint::OptParser.build

        RakeFileUtils.send(:verbose, true) do
          linter = PuppetLint.new
          matched_files = FileList['**/*.pp']

          if ignore_paths = PuppetLint.configuration.ignore_paths
            matched_files = matched_files.exclude(*ignore_paths)
          end

          matched_files.to_a.each do |puppet_file|
            linter.file = puppet_file
            linter.run
            linter.print_problems
          end
          abort if linter.errors? || (
            linter.warnings? && PuppetLint.configuration.fail_on_warnings
          )
        end
      end
    end
  end
end

PuppetLint::RakeTask.new
