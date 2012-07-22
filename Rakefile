require 'rake'
require 'rspec/core/rake_task'

task :default => :test
#task :default => [:test, :rdoc]

RSpec::Core::RakeTask.new(:test)

RSpec::Core::RakeTask.new(:cov) do |t|
  t.rcov = true
  t.rcov_opts = '--exclude "spec" --xrefs'
end

### RDOC Tasks ###
require 'rdoc'
if (RDoc::VERSION.split('.') <=> ['2','4','2']) >= 0
  require 'rdoc/task'
  RDoc::Task.new(:rdoc) do |rdoc|
    rdoc.main = "README.md"
    rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
    rdoc.options << "--all"
  end
else
  require 'rake/rdoctask'
  Rake::RDocTask.new(:rdoc) do |rdoc|
    rdoc.main = "README.md"
    rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
    rdoc.options << "--all"
  end
end
