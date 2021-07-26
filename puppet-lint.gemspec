$LOAD_PATH.push(File.expand_path('../lib', __FILE__))
require 'puppet-lint/version'

Gem::Specification.new do |s|
  s.name = 'puppet-lint'
  s.version = PuppetLint::VERSION.dup
  s.homepage = 'https://github.com/puppetlabs/puppet-lint/'
  s.summary = 'Ensure your Puppet manifests conform with the Puppetlabs style guide'
  s.description = 'Checks your Puppet manifests against the Puppetlabs
  style guide and alerts you to any discrepancies.'

  s.files = Dir['CHANGELOG.md', 'HISTORY.md', 'README.md', 'LICENSE', 'lib/**/*', 'bin/**/*', 'spec/**/*']
  s.test_files = s.files.grep(%r{\Aspec/})
  s.executables = s.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.authors = ['Tim Sharpe', 'Puppet, Inc.', 'Community Contributors']
  s.email = ['tim@sharpe.id.au', 'modules-team@puppet.com']
  s.license = 'MIT'
end
