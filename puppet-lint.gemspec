Gem::Specification.new do |s|
  s.name = 'puppet-lint'
  s.version = '0.0.1'
  s.homepage = 'https://github.com/rodjek/puppet-lint/'
  s.summary = 'Ensure your Puppet manifests conform with the Puppetlabs style guide'
  s.description = 'Checks your Puppet manifests against the Puppetlabs
  style guide and alerts you to any discrepancies.'

  s.files = [
    'bin/puppet-lint',
    'lib/puppet-lint/plugin.rb',
    'lib/puppet-lint/plugins/check_strings.rb',
    'lib/puppet-lint/plugins.rb',
    'lib/puppet-lint.rb',
    'puppet-lint.gemspec',
    'README.md',
  ]

  s.add_development_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
