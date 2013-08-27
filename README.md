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

While right to left relationships are perfectly valid, it's highly recommended
that you don't use them as most people think and read from left to right and
this can lead to confusion.

Bad:

```
Service['httpd'] <- Package['httpd']
```

Good:

```
Package['httpd'] -> Service['httpd']
```

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

### parameter_order

```
WARNING: optional parameter listed before required parameter on line X
```

In parameterised class and defined type definitions, parameters that are
required should be listed before optional parameters (those with default
values).

Bad:

```
class foo($bar='baz', $gronk) {
```

Good:

```
class foo($gronk, $bar='baz') {
```

### inherits_across_namespaces

Inheritance may be used within a module, but must not be used across module
namespaces. Cross-module dependencies should be satisfied in a more portable
way that doesn’t violate the concept of modularity, such as with include
statements or relationship declarations.

Bad:

```
class ssh inherits server { }

class ssh::client inherits workstation { }

class wordpress inherits apache { }
```

Good:

```
class ssh { }

class ssh::client inherits ssh { }

class ssh::server inherits ssh { }

class ssh::server::solaris inherits ssh::server { }
```

### nested_classes_or_defines

Placeholder

### variable_scope

When using top-scope variables, including facts, Puppet modules should explicitly
specify the empty namespace to prevent accidental scoping issues.

Bad:

```
$operatingsystem
```

Good:

```
$::operatingsystem
```

### selector_inside_resource

You should not intermingle conditionals with resource declarations.
When using conditionals for data assignment, you should separate conditional
code from the resource declarations

Bad:

```
file { '/tmp/readme.txt':
  mode => $::operatingsystem ? {
    debian => '0777',
    redhat => '0776',
    fedora => '0007',
  }
}
```

Good:

```
$file_mode = $::operatingsystem ? {
  debian => '0007',
  redhat => '0776',
  fedora => '0007',
}

file { '/tmp/readme.txt':
  mode => $file_mode,
}
```

### case_without_default

Case statements should have default cases. Additionally, the default case should
fail the catalog compilation when the resulting behavior cannot be predicted on
the majority of platforms the module will be used on. If you want the default
case to be “do nothing,” include it as an explicit default: {} for clarity’s sake.

Bad:

```
case $::operatingsystem {
  centos: {
    $version = '1.2.3'
  }
  solaris: {
    $version = '3.2.1'
  }
}
```

Good:

```
case $::operatingsystem {
  centos: {
    $version = '1.2.3'
  }
  solaris: {
    $version = '3.2.1'
  }
  default: {
    fail("Module ${module_name} is not supported on ${::operatingsystem}")
  }
}
```

### unquoted_resource_title

All resource titles should be quoted.

Bad:

```
service { apache:
  ensure => running,
}
```

Good:

```
service { 'apache':
  ensure => running,
}
```

### ensure_first_param

If a resource declaration includes an ensure parameter, it should be the first parameter specified.

Bad:

```
file { '/tmp/foo':
  owner  => 'root',
  group  => 'root',
  ensure => present,
}
```

Good:

```
file { '/tmp/foo':
  ensure => present,
  owner  => 'root',
  group  => 'root',
}
```

### unquoted_file_mode

File modes should be specified as single-quoted strings instead of bare word numbers.

Bad:

```
file { '/tmp/foo':
  mode => 0666,
}
```

Good:

```
file { '/tmp/foo':
  mode => '0666',
}
```

### 4digit_file_mode

File modes should be represented as 4 digits rather than 3, to explicitly show
that they are octal values. File modes can also be represented symbolically
e.g. u=rw,g=r.

Bad:

```
file { '/tmp/foo':
  mode => '666',
}
```

Good:

```
file { '/tmp/foo':
  mode => '0666',
}
```

### ensure_not_symlink_target

In the interest of clarity, symbolic links should be declared by using an ensure
value of ensure => link and explicitly specifying a value for the target attribute.
Using a path to the target as the ensure value is not recommended.

Bad:

```
file { '/tmp/foo':
  ensure => '/tmp/bar',
}
```

Good:

```
file { '/tmp/foo':
  ensure => link,
  target => '/tmp/bar',
}
```

### double_quoted_strings

All strings that do not contain variables or escape characters like \n or \t
should be enclosed in single quotes.

Bad:

```
$foo = "bar"
```

Good:

```
$foo = 'bar'
```

### only_variable_string

Placeholder

### variables_not_enclosed

Placeholder

### single_quote_string_with_variables

Placeholder

### quoted_booleans

Placeholder

### variable_contains_dash

Placeholder

### hard_tabs

Placeholder

### trailing_whitespace

Placeholder

### 80chars

Placeholder

### 2sp_soft_tabs

Placeholder

### arrow_alignment

Placeholder

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
