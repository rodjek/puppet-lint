source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake'
  gem 'rspec-its', '~> 1.0'
  gem 'rspec-collection_matchers', '~> 1.0'

  gem 'rspec', '~> 3.0'
  gem 'json'

  gem 'rspec-json_expectations', '~> 1.4'

  gem 'simplecov', :require => false if ENV['COVERAGE'] == 'yes'
end

group :acceptance do
  gem 'serverspec'
  gem 'puppetlabs_spec_helper'
  gem 'puppet_litmus'
end

group :development do
    gem 'github_changelog_generator', '~> 1.15.0', require: false
    gem 'faraday-retry', require: false
    gem 'pry', require: false
    gem 'pry-byebug', require: false
    gem 'pry-stack_explorer', require: false
end

group :rubocop do
    gem 'rubocop', '~> 1.48.1', require: false
    gem 'rubocop-rspec', '~> 2.19', require: false
    gem 'rubocop-performance', '~> 1.16', require: false
end
