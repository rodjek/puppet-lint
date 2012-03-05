require 'puppet-lint'
require 'rake'
require 'rake/tasklib'

class PuppetLint
  class RakeTask < ::Rake::TaskLib
    def initialize(*args)
      desc 'Run puppet-lint'

      task :lint do
        RakeFileUtils.send(:verbose, true) do
          linter = PuppetLint.new('**/*.pp')
          linter.run
          fail if linter.errors?
        end
      end
    end
  end
end

PuppetLint::RakeTask.new
