require 'puppet-lint'
require 'rake'
require 'rake/tasklib'

class PuppetLint
  class RakeTask < ::Rake::TaskLib
    def initialize(*args)
      desc 'Run puppet-lint'

      task :lint do
        PuppetLint.configuration.with_filename = true

        RakeFileUtils.send(:verbose, true) do
          linter = PuppetLint.new
          matched_files = FileList['**/*.pp']

          if ignore_paths = PuppetLint.configuration.ignore_paths
            matched_files = matched_files.exclude(*ignore_paths)
          end

          matched_files.to_a.each do |puppet_file|
            linter.file = puppet_file
            linter.run
          end
          fail if linter.errors? || (
            linter.warnings? && PuppetLint.configuration.fail_on_warnings
          )
        end
      end
    end
  end
end

PuppetLint::RakeTask.new
