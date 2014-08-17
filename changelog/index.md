---
layout: default
---

# Changelog

---

### 0.3.2

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.3.1...0.3.2)

#### Bug fixes

 * Fixed bug in the `String#%` monkeypatch that broke Facter under Ruby 1.8.
 * Fixed bug in lexer that caused puppet-lint to crash when tokenising a string
   containing multiple backslashes immediately followed by an escaped quote.
 * Fixed bug in puppet-lint that caused it to crash when trying to read
   configuration options from a file in the users home directory if the HOME
   environment variable is not set.
 * Provide a nice error message when passed a malformed manifest file instead
   of a backtrace.
 * Fixed bug in the `class_parameter_defaults` check that prevented it from
   reporting all instances of the problem under certain circumstances.

---

### 0.3.1

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.3.0...0.3.1)

#### Bug fixes

 * Fixed bug in the `class_inherits_from_params_class` check where it would
   throw an exception when checking a class with a comment directly above it.

---

### 0.3.0

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.2.1...0.3.0)

#### New features

 * Split the `parameterised_class` class check into two checks:
   `class_inherits_from_params_class` and `class_parameter_defaults`.
 * Added the `--with-context` option to have `puppet-lint` print out the line
   of the manifest with a marker pointing to the exact location of the detected
   problem.

#### Bug fixes

 * Fixed bug in the puppet-lint executable that prevented it from returning a
   non-zero exit code on error.
 * Fixed bug in duplicate parameter check where nested resources and hashes
   could trigger a false positive result.
 * Fixed bug in the lexer where strings ending in `\\` would cause the program
   to crash.
 * Fixed false positive result when inheriting from non-parent classes within
   the same module namespace.
 * Changed the language of the `arrow_alignment` check to make it more
   understandable.

---

### 0.2.1

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.2.0...0.2.1)

#### Bug fixes

 * Optimised the unquoted\_file\_mode check.
 * Optimised the file\_mode check.
 * Optimised the ensure\_first\_param check.
 * Optimised the ensure\_not\_symlink\_target check.
 * Optimised the plugin structure to significantly improve performance.
 * Fixed bug in the parameterised\_class check to correctly detect
   non-parameterised classes.
 * Fixed bug in the documentation check to handle undocumented classes
   gracefully under Ruby 1.9.x.

---

### 0.2.0

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.13...0.2.0)

#### New features

 * Added the ability to output the column number of problem.
 * Added check for // comments.
 * Added check for /\* \*/ comments.
 * Added check for undocumented classes and defines.
 * Added check for parameterised classes without default values.
 * Added duplicate parameter check.
 * Added check for class/defined type names contain a dash.
 * Added support for reading command line options from /etc/puppet-lint.rc
 * Changed puppet-lint script to allow passing multiple files on the command
   line.

#### Removed features

 * Removed the dependency on Puppet and added a custom lexer for the Puppet
   DSL.
 * Removed the "Evaluating #{file}" output from the Rake task.
 * Reading from `~/.puppet-lintrc` and `./.puppet-lintrc` depreciated in favour
   of `~/.puppet-lint.rc` and `./.puppet-lintrc`.

#### Bug fixes
 * Cleaned up and documented the codebase.
 * Improved test cases to ensure 100% code coverage.
 * Fixed support for running puppet-lint under Ruby 1.9.x.
 * File modes of `undef` are now allowed.
 * Fixed the arrow alignment check to ignore commented lines.
 * Greatly improved reliability in general.

---

### 0.1.13

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.12...0.1.13)

#### New features

 * Added support for passing a directory to bin/puppet-lint.
 * Added support for Puppet 0.25.x

#### Bug fixes

 * Added support for symbolic file modes.
 * Added additional variables that Puppet automatically creates in the local
   scope to the exceptions list in the scoped variable check.

---

### 0.1.12

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.11...0.1.12)

#### Bug fixes

 * Fixed bug that was detecting parameterised class instantiation as a class
   definition.
 * Changed autoloader layout check to use the expanded path to the file.

---

### 0.1.11

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.10...0.1.11)

#### Bug fixes

 * Added Ruby 1.9 support

---

### 0.1.10

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.9...0.1.10)

#### New features

 * Added support for reading options from .puppet-lintrc
 * Added --log-format option to bin/puppet-lint to allow people to specify
   their own error format.

#### Bug fixes

 * Added $title, $module\_name and $n variables to the exceptions to the scoped
   variables check.
 * Split each check out into a seperate function.
 * Moved all configuration logic into PuppetLint::Configuration class.

---

### 0.1.9

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.8...0.1.9)

#### Bug fixes

 * Cleaned up option checking logic in bin/puppet-lint

---

### 0.1.8

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.7...0.1.8)

#### New features

 * Added check for variable names containing a dash.
 * Added check for quoted boolean values.
 * Added option to bin/puppet-lint to print out the filename with errors.
 * Added option for selective error level reporting to bin/puppet-lint.
 * Added autoloader path layout check.

#### Bug fixes

 * Fixed false positive result when type parameters have a default value that
   is a variable.
 * Fixed arrow alignment check to allow an infinite level of indentation.

---

### 0.1.7

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.4...0.1.7)

#### Bug fixes

 * Changed bin/puppet-lint so that it returns 1 on error.
 * Fixed bug where calling a parameterised class raised a false positive.
 * Changed puppet-lint to gracefully fail when it can't load puppet.

---

### 0.1.4

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.3...0.1.4)

#### Bug fixes

 * Allowed tabs or newlines in double quoted strings without throwing an error.

---

### 0.1.3

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.2...0.1.3)

#### Bug fixes

 * Fixed bug in detecting the end of a selector nested within a resource when
   checking arrow alignment.

---

### 0.1.2

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.1...0.1.2)

#### Bug fixes

 * Monkey patched the Puppet lexer to put single quoted strings into a new
   \:SSTRING token type.
 * Converted CheckStrings to using the lexer instead of regexes.

---

### 0.1.1

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.1.0...0.1.1)

#### Bug fixes

 * Added exception to the scoped variables check for $name.

---

### 0.1.0

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.7...0.1.0)

#### New features

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

#### Bug fixes

 * Fix bug with selector indent level when nested in a resource when checking
   arrow alignment.
 * Removed duplicate check that detects a selector nested inside a resource
   instance.

---

### 0.0.7

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.6...0.0.7)

 * Moved the Rake task into the PuppetLint class.
 * Documented puppet-lint in the form of a README.

---

### 0.0.6

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.5...0.0.6)

 * Added support for nested selectors inside resources when detecting arrow
   alignment.
 * Add exception for the 80 character line check to not alert if the line
   contains a puppet:// URL.

---

### 0.0.5

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.4...0.0.5)

 * Fixed unquoted resource check so that it doesn't analyse case statements.
 * MIT license.
 * Fixed CheckStrings so that it won't mistakenly check strings in strings.

---

### 0.0.4

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.3...0.0.4)

 * Rewrote CheckResources plugin to use Puppet's lexer as a proof of concept.
 * Added some error handling to cover when puppet-lint has no code to evaluate.

---

### 0.0.3

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.2...0.0.3)

 * Fixed string checks to allow for empty double quoted strings.
 * Fixed first attribute detection in resources check.

---

### 0.0.2

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.0.1...0.0.2)

 * Added an importable Rake task.
 * Added check for lines containing hard tabs.
 * Added check for lines with trailing whitespace.
 * Added check for lines longer than 80 characters.
 * Added check for indents not using 2 space soft tabs.
 * Added check for unaligned arrows.
 * Added check for unquoted resource titles.
 * Added check for resources where ensure isn't the first parameter.
 * Added check for file modes that aren't 4 digit octal values.

---

### 0.0.1

 * Initial release!
 * Didn't really do much except some basic checking of quoted strings.
