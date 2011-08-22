# Puppet-lint

The goal of this project is to implement as many of the recommended Puppet
style guidelines from the [Puppetlabs style
guide](http://docs.puppetlabs.com/guides/style_guide.html) as practical.

## Installation

    gem install puppet-lint

## Testing your manifests

You can test a single manifest file by running

    puppet-lint <path to file>

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
 * All strings that contain variables must be enclosed in double quotes.
 * All variables should be enclosed in braces when interpolated in a string.
 * Variables standing by themselves should not be quoted.

### Resources

 * All resource titles should be quoted.
 * If a resource declaration includes an `ensure` attribute, it should be the
   first attribute specified.
 * Symbolic links should be declared by using an ensure value of `link` and
   explicitly specifying a value for the `target` attribute.
 * File modes should be represented as a 4 digit string enclosed in single
   quotes.

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
 # When using top-scope variables, including facts, Puppet modules should
   explicitly specify the empty namespace.

## Reporting bugs or incorrect results

If you find a bug in puppet-lint or its results, please create an issue in the
[repo issues tracker](https://github.com/rodjek/puppet-lint/issues/).  Bonus
points will be awarded if you also include a patch that fixes the issue.
