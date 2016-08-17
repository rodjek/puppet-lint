$:.push File.expand_path("../lib", __FILE__)
require 'puppet-lint/version'

Gem::Specification.new do |s|
  s.name = 'puppet-lint'
  s.version = PuppetLint::VERSION
  s.homepage = 'https://github.com/rodjek/puppet-lint/'
  s.summary = 'Ensure your Puppet manifests conform with the Puppetlabs style guide'
  s.description = 'Checks your Puppet manifests against the Puppetlabs
  style guide and alerts you to any discrepancies.'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its', '~> 1.0'
  s.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  s.add_development_dependency 'github_changelog_generator'
  s.add_development_dependency 'rack', '~> 1.0'

  if RUBY_VERSION < '2.0'
    # json 2.x requires ruby 2.0. Lock to 1.8
    s.add_development_dependency 'json', '~> 1.8'
    # json_pure 2.0.2 requires ruby 2.0. Lock to 2.0.1
    s.add_development_dependency 'json_pure', '= 2.0.1'
    # addressable 2.4.0 requires ruby 1.9.0. Lock to 2.3.8.
    s.add_development_dependency 'addressable', '= 2.3.8'
  else
    s.add_development_dependency 'json'
  end

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
