require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint'

task :default => :test

RSpec::Core::RakeTask.new(:test)

begin
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    version = PuppetLint::VERSION
    config.future_release = "#{version}"
    config.exclude_labels = %w{duplicate question invalid wontfix}
  end
rescue LoadError
end

# vim: syntax=ruby
