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

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
