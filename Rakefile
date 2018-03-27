require 'rake'
require 'rspec/core/rake_task'
require 'puppet-lint'
require 'puppet-lint/tasks/release_test'

task :default => :test

RSpec::Core::RakeTask.new(:test)

begin
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new(:changelog) do |config|
    version = PuppetLint::VERSION
    config.future_release = version.to_s
    config.exclude_labels = %w[duplicate question invalid wontfix release-pr documentation]
    config.enhancement_labels = %w[feature]
  end
rescue LoadError
  $stderr.puts 'Changelog generation requires Ruby 2.0 or higher'
end

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = %w[-D -E]
    task.patterns = [
      'lib/**/*.rb',
      'spec/**/*.rb',
      'bin/*',
      '*.gemspec',
      'Gemfile',
      'Rakefile',
    ]
  end
rescue LoadError
  $stderr.puts 'Rubocop is not available for this version of Ruby.'
end

task :ci => [:test, :release_test]

# vim: syntax=ruby
