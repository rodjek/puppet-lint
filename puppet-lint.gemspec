$LOAD_PATH.push(File.expand_path('lib', __dir__))
require 'puppet-lint/version'

Gem::Specification.new do |spec|
  spec.name = 'puppet-lint'
  spec.version = PuppetLint::VERSION.dup
  spec.homepage = 'https://github.com/puppetlabs/puppet-lint/'
  spec.summary = 'Ensure your Puppet manifests conform with the Puppetlabs style guide'
  spec.description = <<-EOF
    Checks your Puppet manifests against the Puppetlabs style guide and alerts you to any discrepancies.
  EOF

  spec.files = Dir[
    'README.md',
    'LICENSE',
    'rubocop_baseline.yml',
    'lib/**/*',
    'bin/**/*',
    'spec/**/*',
  ]
  spec.executables = Dir['bin/**/*'].map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.authors = [
    'Tim Sharpe',
    'Puppet, Inc.',
    'Community Contributors',
  ]
  spec.email = [
    'tim@sharpe.id.au',
    'modules-team@puppet.com',
  ]
  spec.license = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.7'.freeze)
end
