##2016/06/22 - Releasing 2.0.0

puppet-lint 2.0.0 is a breaking change. Specifically, the renaming of the line length test was changed from `80chars` to `140chars`. You may need to adjust your configuration and lint checks. For example:
```ruby
# Line length test is 80 chars in puppet-lint 1.1.0
PuppetLint.configuration.send('disable_80chars')
# Line length test is 140 chars in puppet-lint 2.x
PuppetLint.configuration.send('disable_140chars')
# Disable all line length checks
PuppetLint.configuration.send('disable_char_check')
```

You may also need to adjust your Gemfile if you are pointing directly at git:
```ruby
# old
gem 'puppet-lint', :require => false, :git => 'https://github.com/rodjek/puppet-lint.git'

# new
gem 'puppet-lint', '~> 2.0'
```

If the additional gems you use for checks are pinned to 1.x, you should pin puppet-lint to `'~> 1.0'` or `'>= 1.0', '< 3.0'` until updated check gems are released.
