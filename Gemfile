source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake', '~> 10.0'
  gem 'rspec-its', '~> 1.0'
  gem 'rspec-collection_matchers', '~> 1.0'

  gem 'rspec', '~> 3.0'
  gem 'json'

  gem 'rspec-json_expectations', '~> 1.4'

  gem 'simplecov', :require => false if ENV['COVERAGE'] == 'yes'
end

group :development do
    gem 'github_changelog_generator', require: false
    gem 'faraday-retry', require: false
    gem 'pry', require: false
end

group :rubocop do
    gem 'rubocop', '~> 1.6.1', require: false
    gem 'rubocop-rspec', '~> 2.0.1', require: false
    gem 'rubocop-performance', '~> 1.9.1', require: false
end
