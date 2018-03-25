# Puppet Lint

[![Build
Status](https://secure.travis-ci.org/rodjek/puppet-lint.png)](http://travis-ci.org/rodjek/puppet-lint)
[![Inline docs](http://inch-ci.org/github/rodjek/puppet-lint.png?branch=master)](http://inch-ci.org/github/rodjek/puppet-lint)

Puppet Lint tests Puppet code against the recommended [Puppet language style
guide](http://puppet.com/docs/puppet/latest/style_guide.html). Puppet Lint validates only code style; it does not validate syntax. To test syntax, use Puppet's `puppet parser validate` command.

## Compatibility warning

Puppet Lint version 2 is the last planned version with support for Puppet 3 and Ruby 1.8.7. The next major version of Puppet Lint will drop support for these versions.

## Installation

Install the Puppet Lint gem by running:

```
gem install puppet-lint
```

## Testing with Puppet Lint

To test manifests for correct Puppet style, run the `puppet-lint` command with the path to the files you want to test.

For example:

```
puppet-lint ~/modules/puppetlabs-java/manifests/init.pp
```

```
puppet-lint ~/modules/puppetlabs-mysql/manifests
```

### Fix issues automatically

To instruct Lint to automatically fix any issues that it detects, use the `--fix` flag:

```
puppet-lint --fix /modules
```

### Modify which checks to run

Puppet Lint options allow you to modify which checks to run. You can disable any of the checks temporarily or permanently, or you can limit testing to specific checks.

#### List all available checks

To list all available checks along with basic usage documentation, use the `--list-checks` option.

#### Run specific checks

To run only specific checks, use the `--only-checks` option, with a comma-separated list of arguments specifying which checks to make:

```
puppet-lint --only-checks trailing_whitespace,140chars modules/
```

To avoid enormous patch sets when using the `--fix` flag, use the `--only-checks` option to limit which checks Puppet Lint makes:

```
puppet-lint --only-checks trailing_whitespace --fix modules/
```

### Disable Lint checks

You can disable specific Lint checks on the command line, disable them permanently with a configuration file, or disable them with control comments within your Puppet code.

#### Disable checks on the command line

To disable any of the checks when running the `puppet-lint` command, add a `--no-<check_name>-check` flag to the command. For example, to skip the 140-character check, run:

```
puppet-lint --no-140chars-check modules/
```

#### Disable checks within Puppet code

To disable checks from within your Puppet code itself, use [control comments](http://puppet-lint.com/controlcomments/). Disable checks on either a per-line or per-block basis using `#lint:ignore:<check_name>`.

For example:

```puppet
class foo {
  $bar = 'bar'

  # This ignores the double_quoted_strings check over multiple lines

  # lint:ignore:double_quoted_strings
  $baz = "baz"
  $gronk = "gronk"
  # lint:endignore

  # This ignores the 140chars check on a single line

  $this_line_has_a_really_long_name_and_value_that_is_much_longer_than_the_style_guide_recommends = "I mean, a really, really long line like you can't believe" # lint:ignore:140chars
}
```

## Configuration file

Each time Puppet Lint starts up, it loads configuration from three files in order:

1. `/etc/puppet-lint.rc`
1. `~/.puppet-lint.rc`
1. `.puppet-lint.rc`

This means that a flag in the local `.puppet-lint.rc` will take precedence over a flag in the global `/etc/puppet-lint.rc`, for example. Flags specified on the command line take final precedence and override all config file options.

Any flag that can be specified on the command line can also be specified in the configuration file. For example, to always skip the hard tab character check, create `~/.puppet-lint.rc` and include the line:

```
--no-hard_tabs-check
```

Or to specify a whitelist of allowed checks, include a line like:

```
--only-checks=trailing_whitespace,hard_tabs,duplicate_params,double_quoted_strings,unquoted_file_mode,only_variable_string,variables_not_enclosed,single_quote_string_with_variables,variable_contains_dash,ensure_not_symlink_target,unquoted_resource_title,relative_classname_inclusion,file_mode,resource_reference_without_title_capital,leading_zero,arrow_alignment,variable_is_lowercase,ensure_first_param,resource_reference_without_whitespace,file_ensure,trailing_comma,leading_zero
```

## Testing with Puppet Lint as a Rake task

To test your entire Puppet manifest directory, add `require 'puppet-lint/tasks/puppet-lint'` to your Rakefile and then run:

```
rake lint
```

To modify the default behaviour of the Rake task, modify the Puppet Lint configuration by defining the task yourself. For example:

```ruby
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
```

### Disable checks in the Lint Rake task

You can also disable checks when running Puppet Lint through the supplied Rake task by modifying your `Rakefile`.

* To disable a check, add the following line after the `require` statement in your `Rakefile`:

  ```ruby
  PuppetLint.configuration.send("disable_<check name>")
  ```

  For example, to disable the 140-character check, add:

  ```ruby
  PuppetLint.configuration.send("disable_140chars")
  ```

* To set the Lint Rake task to ignore certain paths:

  ```ruby
  PuppetLint.configuration.ignore_paths = ["vendor/**/*.pp"]
  ```

* To set a pattern of files that Lint should check:

  ```ruby
  # Defaults to `**/*.pp`
  PuppetLint.configuration.pattern = "modules"
  ```

## Options

See `puppet-lint --help` for a full list of command line options and checks.

## Checks

For a complete list of checks, and how to resolve errors on each check, see the Puppet Lint [checks](http://puppet-lint.com/checks/) page.

### Spacing, Indentation, and Whitespace

* Must use two-space soft tabs.
* Must not use literal tab characters.
* Must not contain trailing white space.
* Should not exceed an 140-character line width.
  * An exception has been made for `source => 'puppet://...'` lines as splitting these over multiple lines decreases the readability of the manifests.
* Should align arrows (`=>`) within blocks of attributes.

### Quoting

* All strings that do not contain variables should be enclosed in single quotes.
  * An exception has been made for double-quoted strings containing \n or \t.
* All strings that contain variables must be enclosed in double quotes.
* All variables should be enclosed in braces when interpolated in a string.
* Variables standing by themselves should not be quoted.

### Capitalization

* All variables should be in lowercase.

### Resources

* All resource titles should be quoted.
  * An exception has been made for resource titles that consist of only a variable standing by itself.
* If a resource declaration includes an `ensure` attribute, it should be the first attribute specified.
* Symbolic links should be declared by using an ensure value of `link` and explicitly specifying a value for the `target` attribute.
* File modes should be represented as a 4-digit string enclosed in single quotes or use symbolic file modes.

### Conditionals

* You should not intermingle conditionals inside resource declarations (that is, selectors inside resources).
* Case statements should have a default case.

### Classes

* Relationship declarations with the chaining syntax should only be used in the 'left to right' direction.
* Classes should not be defined inside a class.
* Defines should not be defined inside a class.
* Classes should not inherit between namespaces.
* Required parameters in class & defined type definitions should be listed before optional parameters.
* When using top-scope variables, including facts, Puppet modules should explicitly specify the empty namespace.
* Chaining operators should appear on the same line as the right hand operand.

## Reporting bugs or incorrect results

If you find a bug in Puppet Lint or its results, please create an issue in the
[repo issues tracker](https://github.com/rodjek/puppet-lint/issues/). Bonus
points will be awarded if you also include a patch that fixes the issue.

## Thank you

Many thanks to the following people for contributing to puppet-lint

* James Turnbull (@kartar)
* Jan Vansteenkiste (@vStone)
* Julian Simpson (@simpsonjulian)
* S. Zachariah Sprackett (@zsprackett)

As well as the many people who have reported the issues they've had!

## License

Copyright (c) 2011-2016 Tim Sharpe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
