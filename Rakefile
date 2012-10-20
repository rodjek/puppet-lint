require 'rake'
require 'rspec/core/rake_task'

task :default => :test

RSpec::Core::RakeTask.new(:test)

RSpec::Core::RakeTask.new(:cov) do |t|
  t.rcov = true
  t.rcov_opts = '--exclude "spec" --xrefs'
end
