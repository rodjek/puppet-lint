# Puppet-lint

[![Build
Status](https://secure.travis-ci.org/rodjek/puppet-lint.png)](http://travis-ci.org/rodjek/puppet-lint)
[![Dependency
Status](https://gemnasium.com/rodjek/puppet-lint.png)](http://gemnasium.com/rodjek/puppet-lint)

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

## Implemented tests

At the moment, the following tests have been implemented:

### Spacing, Indentation & Whitespace

 * Must use two-space soft tabs.
 * Must not use literal tab characters.
 * Must not contain trailing white space.
 * Should not exceed an 80 character line width
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

## Fixing problems

### right_to_left_relationship

```
WARNING: right-to-left (<-) relationship on line X
```

See: [11.3. Relationship Declarations](http://docs.puppetlabs.com/guides/style_guide.html#relationship-declarations)

### autoloader_layout

```
ERROR: mymodule::myclass not in autoload module layout on line X
```

Puppet attempts to autoload only the required manifests for the resources and
classes specified in your manifests.  In order to do this, the autoloader
expects your manifests to be laid out on disk in a particular format.  For
example, when you use `mymodule::myclass` in your manifests, Puppet will
attempt to read `<modulepath>/mymodule/manifests/myclass.pp`.  The only
exception to this is when you reference `mymodule` itself (without any
subclass/subtype) in which case it will read
`<modulepath>/mymodule/manifests/init.pp`.

See: [11.1. Separate Files](http://docs.puppetlabs.com/guides/style_guide.html#separate-files)

### parameter_order

```
WARNING: optional parameter listed before required parameter on line X
```

See: [11.8. Display Order of Class Parameters](http://docs.puppetlabs.com/guides/style_guide.html#display-order-of-class-parameters)

### inherits_across_namespaces

See: [11.5. Class Inheritance](http://docs.puppetlabs.com/guides/style_guide.html#class-inheritance)

### nested_classes_or_defines

Placeholder

### variable_scope

See: [11.6. Namespacing Variables](http://docs.puppetlabs.com/guides/style_guide.html#namespacing-variables)

### selector_inside_resource

See: [10.1. Keep Resource Declarations Simple](http://docs.puppetlabs.com/guides/style_guide.html#keep-resource-declarations-simple)

### case_without_default

See: [10.2. Defaults for Case Statements and Selectors](http://docs.puppetlabs.com/guides/style_guide.html#defaults-for-case-statements-and-selectors)

### unquoted_resource_title

See: [9.1. Resource Names](http://docs.puppetlabs.com/guides/style_guide.html#resource-names)

### ensure_first_param

See: [9.3. Attribute Ordering](http://docs.puppetlabs.com/guides/style_guide.html#attribute-ordering)

### unquoted_file_mode

See: [9.6. File Modes](http://docs.puppetlabs.com/guides/style_guide.html#file-modes)

### 4digit_file_mode

See: [9.6. File Modes](http://docs.puppetlabs.com/guides/style_guide.html#file-modes)

### ensure_not_symlink_target

See: [9.5. Symbolic Links](http://docs.puppetlabs.com/guides/style_guide.html#symbolic-links)

### double_quoted_strings

See: [8. Quoting](http://docs.puppetlabs.com/guides/style_guide.html#quoting)

### only_variable_string

See: [8. Quoting](http://docs.puppetlabs.com/guides/style_guide.html#quoting)

### variables_not_enclosed

See: [8. Quoting](http://docs.puppetlabs.com/guides/style_guide.html#quoting)

### single_quote_string_with_variables

Single quoted strings do not get interpolated, so you should not attempt to embed
variables in one. This is not a style issue, rather a common mistake.

Bad:

```
$foo = 'bar ${baz}'
```

Good:

```
$foo = "bar ${baz}"
```

### quoted_booleans

Boolean values (true and false) behave differently when quoted ('true' and
'false'), which can lead to a fair bit of confusion. As a general rule, you
should never quote booleans. This is not a style issue, rather a common mistake.

Bad:

```
file { '/tmp/foo':
  purge => 'true',
}
```

Good:

```
file { '/tmp/foo':
  purge => true,
}
```
 
### variable_contains_dash

See: [11.7. Variable format](http://docs.puppetlabs.com/guides/style_guide.html#variable-format)

### hard_tabs

See: [6. Spacing, Indentation, & Whitespace](http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace)

### trailing_whitespace

See: [6. Spacing, Indentation, & Whitespace](http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace)

### 80chars

See: [6. Spacing, Indentation, & Whitespace](http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace)

### 2sp_soft_tabs

See: [6. Spacing, Indentation, & Whitespace](http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace)

### arrow_alignment

See: [6. Spacing, Indentation, & Whitespace](http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace)

## Disabling checks

### puppet-lint

You can disable any of the checks when running the `puppet-lint` command by
adding a `--no-<check name>-check` flag to the command.  For example, if you
wanted to skip the 80 character check, you would run

```
puppet-lint --no-80chars-check /path/to/my/manifest.pp
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

So, to disable the 80 character check, you would add:

``` ruby
PuppetLint.configuration.send("disable_80chars")
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

Copyright (c) 2011 Tim Sharpe

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
