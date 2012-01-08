require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

task :default => :test
#task :default => [:test, :rdoc]

RSpec::Core::RakeTask.new(:test)
Rake::RDocTask.new(:rdoc) do |rd|
  rd.main = "README.md"
  rd.rdoc_files.include("README.md", "lib/**/*.rb")
  rd.options << "--all"
end
