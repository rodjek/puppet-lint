---
layout: default
---

# Changelog

### 0.2.1

 * Optimised the unquoted\_file\_mode check.
 * Optimised the file\_mode check.
 * Optimised the ensure\_first\_param check.
 * Optimised the ensure\_not\_symlink\_target check.
 * Optimised the plugin structure to significantly improve performance.
 * Fixed bug in the parameterised\_class check to correctly detect
   non-parameterised classes.
 * Fixed bug in the documentation check to handle undocumented classes
   gracefully under Ruby 1.9.x.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.2.0...0.2.1)

### 0.2.0

 * Removed the dependency on Puppet and added a custom lexer for the Puppet
   DSL.
 * Added the ability to output the column number of problem.
 * Cleaned up and documented the codebase.
 * Added check for // comments.
 * Added check for /\* \*/ comments.
 * Added check for undocumented classes and defines.
 * Improved test cases to ensure 100% code coverage.
 * Added check for parameterised classes without default values.
 * Fixed support for running puppet-lint under Ruby 1.9.x.
 * Added duplicate parameter check.
 * Changed puppet-lint script to allow passing multiple files on the command
   line.
 * Removed the "Evaluating #{file}" output from the Rake task.
 * File modes of `undef` are now allowed.
 * Added check for class/defined type names contain a dash.
 * Fixed the arrow alignment check to ignore commented lines.
 * Added support for reading command line options from /etc/puppet-lint.rc
 * Reading from `~/.puppet-lintrc` and `./.puppet-lintrc` depreciated in favour
   of `~/.puppet-lint.rc` and `./.puppet-lintrc`.
 * Greatly improved reliability in general.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.13...0.2.0)

### 0.1.13

 * Added support for symbolic file modes.
 * Added additional variables that Puppet automatically creates in the local
   scope to the exceptions list in the scoped variable check.
 * Added support for passing a directory to bin/puppet-lint.
 * Added support for Puppet 0.25.x
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.12...0.1.13)

### 0.1.12

 * Fixed bug that was detecting parameterised class instantiation as a class
   definition.
 * Changed autoloader layout check to use the expanded path to the file.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.11...0.1.12)

### 0.1.11

 * Added Ruby 1.9 support
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.10...0.1.11)

### 0.1.10

 * Added $title, $module\_name and $n variables to the exceptions to the scoped
   variables check.
 * Split each check out into a seperate function.
 * Added support for reading options from .puppet-lintrc
 * Moved all configuration logic into PuppetLint::Configuration class.
 * Added --log-format option to bin/puppet-lint to allow people to specify
   their own error format.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.9...0.1.10)

### 0.1.9

 * Cleaned up option checking logic in bin/puppet-lint
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.8...0.1.9)

### 0.1.8

 * Added check for variable names containing a dash.
 * Added check for quoted boolean values.
 * Fixed false positive result when type parameters have a default value that
   is a variable.
 * Fixed arrow alignment check to allow an infinite level of indentation.
 * Added option to bin/puppet-lint to print out the filename with errors.
 * Added option for selective error level reporting to bin/puppet-lint.
 * Added autoloader path layout check.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.7...0.1.8)

### 0.1.7

 * Changed bin/puppet-lint so that it returns 1 on error.
 * Fixed bug where calling a parameterised class raised a false positive.
 * Changed puppet-lint to gracefully fail when it can't load puppet.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.4...0.1.7)

### 0.1.4

 * Allowed tabs or newlines in double quoted strings without throwing an error.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.3...0.1.4)

### 0.1.3

 * Fixed bug in detecting the end of a selector nested within a resource when
   checking arrow alignment.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.2...0.1.3)

### 0.1.2

 * Monkey patched the Puppet lexer to put single quoted strings into a new
   \:SSTRING token type.
 * Converted CheckStrings to using the lexer instead of regexes.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.1...0.1.2)

### 0.1.1

 * Added exception to the scoped variables check for $name.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.0...0.1.1)

### 0.1.0

 * Added check for file resources that create symlinks without using the
   target attribute.
 * Added check for selectors that are nested in resource instances.
 * Added check for strings that only contain a variable.
 * Added check for case statements that don't have a default case.
 * Added check for any right to left resource chains.
 * Added check for defined types or classes nested inside other classes.
 * Added check for classes that inherit across namespaces.
 * Added check for defined types and parameterised classes parameter ordering.
 * Added check for variable scoping.
 * Fix bug with selector indent level when nested in a resource when checking
   arrow alignment.
 * Removed duplicate check that detects a selector nested inside a resource
   instance.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.7...0.1.0)

### 0.0.7

 * Moved the Rake task into the PuppetLint class.
 * Documented puppet-lint in the form of a README.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.6...0.0.7)

### 0.0.6

 * Added support for nested selectors inside resources when detecting arrow
   alignment.
 * Add exception for the 80 character line check to not alert if the line
   contains a puppet:// URL.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.5...0.0.6)

### 0.0.5

 * Fixed unquoted resource check so that it doesn't analyse case statements.
 * MIT license.
 * Fixed CheckStrings so that it won't mistakenly check strings in strings.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.4...0.0.5)

### 0.0.4

 * Rewrote CheckResources plugin to use Puppet's lexer as a proof of concept.
 * Added some error handling to cover when puppet-lint has no code to evaluate.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.3...0.0.4)

### 0.0.3

 * Fixed string checks to allow for empty double quoted strings.
 * Fixed first attribute detection in resources check.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.2...0.0.3)

### 0.0.2

 * Added an importable Rake task.
 * Added check for lines containing hard tabs.
 * Added check for lines with trailing whitespace.
 * Added check for lines longer than 80 characters.
 * Added check for indents not using 2 space soft tabs.
 * Added check for unaligned arrows.
 * Added check for unquoted resource titles.
 * Added check for resources where ensure isn't the first parameter.
 * Added check for file modes that aren't 4 digit octal values.
 * [View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.1...0.0.2)

### 0.0.1

 * Initial release!
 * Didn't really do much except some basic checking of quoted strings.
