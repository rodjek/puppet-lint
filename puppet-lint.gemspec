Gem::Specification.new do |s|
  s.name = 'puppet-lint'
  s.version = '0.1.8'
  s.homepage = 'https://github.com/rodjek/puppet-lint/'
  s.summary = 'Ensure your Puppet manifests conform with the Puppetlabs style guide'
  s.description = 'Checks your Puppet manifests against the Puppetlabs
  style guide and alerts you to any discrepancies.'

  s.executables = ['puppet-lint']
  s.files = [
    'bin/puppet-lint',
    'lib/puppet-lint/plugin.rb',
    'lib/puppet-lint/plugins/check_classes.rb',
    'lib/puppet-lint/plugins/check_conditionals.rb',
    'lib/puppet-lint/plugins/check_resources.rb',
    'lib/puppet-lint/plugins/check_strings.rb',
    'lib/puppet-lint/plugins/check_variables.rb',
    'lib/puppet-lint/plugins/check_whitespace.rb',
    'lib/puppet-lint/plugins.rb',
    'lib/puppet-lint/tasks/puppet-lint.rb',
    'lib/puppet-lint.rb',
    'LICENSE',
    'puppet-lint.gemspec',
    'Rakefile',
    'README.md',
    'spec/puppet-lint/check_classes_spec.rb',
    'spec/puppet-lint/check_conditionals_spec.rb',
    'spec/puppet-lint/check_resources_spec.rb',
    'spec/puppet-lint/check_strings_spec.rb',
    'spec/puppet-lint/check_variables_spec.rb',
    'spec/puppet-lint/check_whitespace_spec.rb',
    'spec/spec_helper.rb',
  ]

  s.add_development_dependency 'rspec'

  s.authors = ['Tim Sharpe']
  s.email = 'tim@sharpe.id.au'
end
