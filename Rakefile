require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'github_changelog_generator/task'
require 'puppet-lint/version'
require 'rspec/core/rake_task'

begin
  require 'github_changelog_generator/task'
rescue LoadError
  # Gem not present
else
  GitHubChangelogGenerator::RakeTask.new(:changelog) do |config|
    version = PuppetLint::VERSION
    config.user = 'puppetlabs'
    config.project = 'puppet-lint'
    config.since_tag = '2.5.0'
    config.future_release = version.to_s
    config.exclude_labels = %w[duplicate question invalid wontfix release-pr documentation]
    config.enhancement_labels = %w[feature]
  end
end

begin
  require 'puppet_litmus/rake_tasks'
rescue LoadError
  # Gem not present
end

require 'puppetlabs_spec_helper/tasks/fixtures'


RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = 'spec/acceptance/**/*_spec.rb'
end

task :default => :test

