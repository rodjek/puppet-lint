# Puppet-lint

[![Build
Status](https://secure.travis-ci.org/rodjek/puppet-lint.png)](http://travis-ci.org/rodjek/puppet-lint)
[![Inline docs](http://inch-ci.org/github/rodjek/puppet-lint.png?branch=master)](http://inch-ci.org/github/rodjek/puppet-lint)

The goal of this project is to implement as many of the recommended Puppet
style guidelines from the [Puppet Labs style
guide](http://docs.puppetlabs.com/guides/style_guide.html) as practical. It is not meant to validate syntax. Please use `puppet parser validate` for that.

## Installation

    gem install puppet-lint

## Testing your manifests

### By hand

You can test a single manifest file by running

    puppet-lint <path to file>

### Rake task

If you want to test your entire Puppet manifest directory, you can add
`require 'puppet-lint/tasks/puppet-lint'` to your Rakefile and then run

    rake lint

If you want to modify the default behaviour of the rake task, you can modify
the PuppetLint configuration by defining the task yourself.

    PuppetLint::RakeTask.new :lint do |config|
      # Pattern of files to check, defaults to `**/*.pp`
      config.pattern = 'modules'

      # Pattern of files to ignore
      config.ignore_paths = ['modules/apt', 'modules/stdlib']

      # List of checks to disable
      config.disable_checks = ['documentation', '140chars']

      # Should puppet-lint prefix it's output with the file being checked,
      # defaults to true
      config.with_filename = false

      # Should the task fail if there were any warnings, defaults to false
      config.fail_on_warnings = true

      # Format string for puppet-lint's output (see the puppet-lint help output
      # for details
      config.log_format = '%{filename} - %{message}'

      # Print out the context for the problem, defaults to false
      config.with_context = true

      # Enable automatic fixing of problems, defaults to false
      config.fix = true

      # Show ignored problems in the output, defaults to false
      config.show_ignored = true

      # Compare module layout relative to the module root
      config.relative = true
    end

## Implemented tests

At the moment, the following tests have been implemented:

### Spacing, Indentation & Whitespace

 * Must use two-space soft tabs.
 * Must not use literal tab characters.
 * Must not contain trailing white space.
 * Should not exceed an 140 character line width
   * An exception has been made for `source => 'puppet://...'` lines as
     splitting these over multiple lines decreases the readability of the
     manifests.
 * Should align arrows (`=>`) within blocks of attributes.

### Quoting

 * All strings that do not contain variables should be enclosed in single
   quotes.
   * An exception has been made for double quoted strings containing \n or \t.
 * All strings that contain variables must be enclosed in double quotes.
 * All variables should be enclosed in braces when interpolated in a string.
 * Variables standing by themselves should not be quoted.

### Resources

 * All resource titles should be quoted.
   * An exception has been made for resource titles that consist of only
     a variable standing by itself.
 * If a resource declaration includes an `ensure` attribute, it should be the
   first attribute specified.
 * Symbolic links should be declared by using an ensure value of `link` and
   explicitly specifying a value for the `target` attribute.
 * File modes should be represented as a 4 digit string enclosed in single
   quotes or use symbolic file modes.

### Conditionals

 * You should not intermingle conditionals inside resource declarations (i.e.
   selectors inside resources).
 * Case statements should have a default case.

### Classes

 * Relationship declarations with the chaining syntax should only be used in
   the 'left to right' direction.
 * Classes should not be defined inside a class.
 * Defines should not be defined inside a class.
 * Classes should not inherit between namespaces.
 * Required parameters in class & defined type definitions should be listed
   before optional parameters.
 * When using top-scope variables, including facts, Puppet modules should
   explicitly specify the empty namespace.

## Disabling checks

### puppet-lint

You can disable any of the checks when running the `puppet-lint` command by
adding a `--no-<check name>-check` flag to the command.  For example, if you
wanted to skip the 140 character check, you would run

```
puppet-lint --no-140chars-check /path/to/my/manifest.pp
```

puppet-lint will also check for a `.puppet-lint.rc` file in the current
directory and your home directory and read in flags from there, so if you
wanted to always skip the hard tab character check, you could create
`~/.puppet-lint.rc` containing

```
--no-hard_tabs-check
```

For a list of all the flags just type:

```
puppet-lint --help
```

### Rake task

You can also disable checks when running puppet-lint through the supplied Rake
task.  Simply add the following line after the `require` statement in your
`Rakefile`.

``` ruby
PuppetLint.configuration.send("disable_<check name>")
```

So, to disable the 140 character check, you would add:

``` ruby
PuppetLint.configuration.send("disable_140chars")
```

The Rake task also supports ignoring certain paths
from being linted:

``` ruby
PuppetLint.configuration.ignore_paths = ["vendor/**/*.pp"]
```

## Reporting bugs or incorrect results

If you find a bug in puppet-lint or its results, please create an issue in the
[repo issues tracker](https://github.com/rodjek/puppet-lint/issues/).  Bonus
points will be awarded if you also include a patch that fixes the issue.

## Thank You

Many thanks to the following people for contributing to puppet-lint

 * James Turnbull (@kartar)
 * Jan Vansteenkiste (@vStone)
 * Julian Simpson (@simpsonjulian)
 * S. Zachariah Sprackett (@zsprackett)

As well as the many people who have reported the issues they've had!

## License

Copyright (c) 2011-2016 Tim Sharpe

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
