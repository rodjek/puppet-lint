source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake', '~> 10.0'
  gem 'rspec', '~> 3.0'
  gem 'rspec-its', '~> 1.0'
  gem 'rspec-collection_matchers', '~> 1.0'
  gem 'rack', '~> 1.0'

  if RUBY_VERSION < '2.0'
    # json 2.x requires ruby 2.0. Lock to 1.8
    gem 'json', '~> 1.8'
    # json_pure 2.0.2 requires ruby 2.0. Lock to 2.0.1
    gem 'json_pure', '= 2.0.1'
    # addressable 2.4.0 requires ruby 1.9.0. Lock to 2.3.8.
    gem 'addressable', '= 2.3.8'
  else
    gem 'json'
  end
end
