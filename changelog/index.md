---
layout: default
---

# Changelog

---

### [2.0.0](https://github.com/rodjek/puppet-lint/tree/2.0.0) (2016-06-22)
[Full Changelog](https://github.com/rodjek/puppet-lint/compare/1.1.0...2.0.0)

puppet-lint 2.0.0 is a breaking change. Specifically, the renaming of the line length test was changed from `80chars` to `140chars`. You may need to adjust your configuration and lint checks. For example:
```ruby
# Line length test is 80 chars in puppet-lint 1.1.0
PuppetLint.configuration.send('disable_80chars')
# Line length test is 140 chars in puppet-lint 2.x
PuppetLint.configuration.send('disable_140chars')
```

You may also need to adjust your Gemfile if you are pointing directly at git:
```ruby
# old
gem 'puppet-lint', :require => false, :git => 'https://github.com/rodjek/puppet-lint.git'

# new
gem 'puppet-lint', '~> 2.0'
```

If the additional gems you use for checks are pinned to 1.x, you should pin puppet-lint to `'~> 1.0'` or `'>= 1.0', '< 3.0'` until updated check gems are released.

**Closed issues:**

- Current package [\#471](https://github.com/rodjek/puppet-lint/issues/471)
- Arrow alignment check not working with semicolons in a \(potential\) multiple resources declaration [\#470](https://github.com/rodjek/puppet-lint/issues/470)
- puppet-lint --fix ".../puppet-lint/plugins/check\_comments.rb:55:in `block in fix': undefined method `value' for nil:NilClass \(NoMethodError\)" [\#461](https://github.com/rodjek/puppet-lint/issues/461)
- WARNING: indentation of =\> is not properly aligned [\#447](https://github.com/rodjek/puppet-lint/issues/447)
- Inheritance check [\#436](https://github.com/rodjek/puppet-lint/issues/436)
- puppet-lint still checks for lines with more than 80 character [\#425](https://github.com/rodjek/puppet-lint/issues/425)
- puppet-lint --help does not work [\#423](https://github.com/rodjek/puppet-lint/issues/423)
- Test that "ensure" non-filename attributes are barewords [\#412](https://github.com/rodjek/puppet-lint/issues/412)
- crashing puppet-lint 1.1.0 [\#409](https://github.com/rodjek/puppet-lint/issues/409)
- Small Documentation Typo [\#408](https://github.com/rodjek/puppet-lint/issues/408)
- Create v1.1.1 [\#401](https://github.com/rodjek/puppet-lint/issues/401)
- TypeError running on seemingly-sane puppet file [\#399](https://github.com/rodjek/puppet-lint/issues/399)
- Warning for line-length should be at 140 chars [\#396](https://github.com/rodjek/puppet-lint/issues/396)
- Add fix for puppet\_url\_without\_modules check [\#390](https://github.com/rodjek/puppet-lint/issues/390)
- How to disable some fix ? [\#383](https://github.com/rodjek/puppet-lint/issues/383)
- indentation of =\> is not properly aligned [\#381](https://github.com/rodjek/puppet-lint/issues/381)
- parser error on modulo operator [\#379](https://github.com/rodjek/puppet-lint/issues/379)
- Trailing blank lines discarded in PuppetLinter::Data.manifest\_lines [\#378](https://github.com/rodjek/puppet-lint/issues/378)
- nasty bug leading to --no-star\_comments-check to not being honored with --fix [\#373](https://github.com/rodjek/puppet-lint/issues/373)
- Puppet-lint for EPEL7 [\#372](https://github.com/rodjek/puppet-lint/issues/372)
- puppet-lint failure for resource declarations with colons followed by non-whitespaces [\#370](https://github.com/rodjek/puppet-lint/issues/370)
- Issue with puppet-lint 1.1.0 binary on lucid [\#364](https://github.com/rodjek/puppet-lint/issues/364)
- Immediate action required: custom Pages domain pointed to a legacy IP address [\#363](https://github.com/rodjek/puppet-lint/issues/363)
- 1.1.0 ignores trailing white spaces on lines without text [\#359](https://github.com/rodjek/puppet-lint/issues/359)
- alignment warning on commented code [\#357](https://github.com/rodjek/puppet-lint/issues/357)
- gem missing when installing with Puppet [\#356](https://github.com/rodjek/puppet-lint/issues/356)
- --fix ignores control comment\(s\) and fixes anyway [\#347](https://github.com/rodjek/puppet-lint/issues/347)
- colon after closing of class causing puppet-lint to crash. [\#344](https://github.com/rodjek/puppet-lint/issues/344)
- New problem in unqouted\_node\_name check in 1.1.0 [\#343](https://github.com/rodjek/puppet-lint/issues/343)
- whitespace check bug [\#339](https://github.com/rodjek/puppet-lint/issues/339)
- 57fd065d0c2c116471cb16afec99631803496659 breaks indentation of =\> check [\#338](https://github.com/rodjek/puppet-lint/issues/338)
- Error in Jenkins [\#337](https://github.com/rodjek/puppet-lint/issues/337)
- Line numbers in developer tutorial documentation. [\#336](https://github.com/rodjek/puppet-lint/issues/336)
- '--relative' option doesn't work with new RakeTask format introduced in 1.1.0 [\#335](https://github.com/rodjek/puppet-lint/issues/335)
- Configuring RakeTask does not work anymore [\#331](https://github.com/rodjek/puppet-lint/issues/331)
- "indentation of =\> is not properly aligned" for hash inside resource definition [\#327](https://github.com/rodjek/puppet-lint/issues/327)
- --fix doesn't change "\$var" to single-quotes [\#313](https://github.com/rodjek/puppet-lint/issues/313)

**Merged pull requests:**

- \(GH443\) Release 2.0.0 PR [\#477](https://github.com/rodjek/puppet-lint/pull/477) ([rnelson0](https://github.com/rnelson0))
- Fix arrow aligment check in multiple resources declaration [\#476](https://github.com/rodjek/puppet-lint/pull/476) ([wybczu](https://github.com/wybczu))
- Fix issue \#450: block-local variables aren't recognized with subscripts [\#453](https://github.com/rodjek/puppet-lint/pull/453) ([jearls](https://github.com/jearls))
- Adding package\_ensure plugin [\#448](https://github.com/rodjek/puppet-lint/pull/448) ([danzilio](https://github.com/danzilio))
- Update documentation for 140chars [\#440](https://github.com/rodjek/puppet-lint/pull/440) ([keeleysam](https://github.com/keeleysam))
- Changed character width to 140. [\#419](https://github.com/rodjek/puppet-lint/pull/419) ([potto007](https://github.com/potto007))
- Fix arrow\_alignment check to not raise exception when line isn't indented [\#413](https://github.com/rodjek/puppet-lint/pull/413) ([rodjek](https://github.com/rodjek))
- Fix puppet:// url check to catch double quoted strings [\#407](https://github.com/rodjek/puppet-lint/pull/407) ([paulgeringer](https://github.com/paulgeringer))
- Load puppet-lint plugins from Puppet modules [\#404](https://github.com/rodjek/puppet-lint/pull/404) ([raphink](https://github.com/raphink))
- Get ignore\_paths from the configuration [\#397](https://github.com/rodjek/puppet-lint/pull/397) ([lazyfrosch](https://github.com/lazyfrosch))
- Skip checks on empty files [\#393](https://github.com/rodjek/puppet-lint/pull/393) ([vStone](https://github.com/vStone))
- Add the fix functionality to puppet\_url\_without\_modules [\#391](https://github.com/rodjek/puppet-lint/pull/391) ([someword](https://github.com/someword))
- Add various helper functions [\#389](https://github.com/rodjek/puppet-lint/pull/389) ([raphink](https://github.com/raphink))
- Support older 1.8.7 patch numbers Kernel\#caller output [\#387](https://github.com/rodjek/puppet-lint/pull/387) ([rodjek](https://github.com/rodjek))
- Detect trailing whitespace on lines with no code [\#386](https://github.com/rodjek/puppet-lint/pull/386) ([rodjek](https://github.com/rodjek))
- Save the raw value of MLCOMMENT tokens to use when rendering back to a manifest [\#385](https://github.com/rodjek/puppet-lint/pull/385) ([rodjek](https://github.com/rodjek))
- Don't suppress nil values in manifest\_lines [\#384](https://github.com/rodjek/puppet-lint/pull/384) ([rodjek](https://github.com/rodjek))
- Update index.md [\#377](https://github.com/rodjek/puppet-lint/pull/377) ([mcanevet](https://github.com/mcanevet))
- Only clear task if it's already defined [\#376](https://github.com/rodjek/puppet-lint/pull/376) ([domcleal](https://github.com/domcleal))
- add strict\_indent check to community plugins [\#371](https://github.com/rodjek/puppet-lint/pull/371) ([relud](https://github.com/relud))
- Nested cases [\#368](https://github.com/rodjek/puppet-lint/pull/368) ([jonnangle](https://github.com/jonnangle))
- rpearce: Allow the use of facts\[\] and trusted\[\] as per Puppet 3.5+ [\#362](https://github.com/rodjek/puppet-lint/pull/362) ([rjpearce](https://github.com/rjpearce))
- plugins: Add absolute template path check [\#353](https://github.com/rodjek/puppet-lint/pull/353) ([3flex](https://github.com/3flex))
- Update index.md [\#352](https://github.com/rodjek/puppet-lint/pull/352) ([mcanevet](https://github.com/mcanevet))
- Add node\_indexes method [\#351](https://github.com/rodjek/puppet-lint/pull/351) ([mcanevet](https://github.com/mcanevet))
- Don't attempt to fix ignored problems [\#349](https://github.com/rodjek/puppet-lint/pull/349) ([rodjek](https://github.com/rodjek))
- Handle case where a colon is the last token in a file [\#346](https://github.com/rodjek/puppet-lint/pull/346) ([rodjek](https://github.com/rodjek))
- Fix bug in unquoted\_node\_name to support multiple node blocks [\#345](https://github.com/rodjek/puppet-lint/pull/345) ([rodjek](https://github.com/rodjek))
- Catch Errno::EACCES when reading a puppet-lint.rc out of HOME [\#342](https://github.com/rodjek/puppet-lint/pull/342) ([rodjek](https://github.com/rodjek))
- Generate line numbers for the plugin tutorial code examples [\#340](https://github.com/rodjek/puppet-lint/pull/340) ([rodjek](https://github.com/rodjek))
- Add support for '--relative' option in new Rake::Task format. [\#334](https://github.com/rodjek/puppet-lint/pull/334) ([fatmcgav](https://github.com/fatmcgav))
- fix \#331 - clear any pre-\(auto-\)existing tasks [\#332](https://github.com/rodjek/puppet-lint/pull/332) ([duritong](https://github.com/duritong))
- Don't warn for arrow alignment for single-element hashes [\#330](https://github.com/rodjek/puppet-lint/pull/330) ([domcleal](https://github.com/domcleal))
- Document multiple commands in a single control comment [\#329](https://github.com/rodjek/puppet-lint/pull/329) ([domcleal](https://github.com/domcleal))
- Add parameter\_documentation/param-docs plugin [\#328](https://github.com/rodjek/puppet-lint/pull/328) ([domcleal](https://github.com/domcleal))
- Alternative to \#289: :error on either class names and defines [\#290](https://github.com/rodjek/puppet-lint/pull/290) ([ppp0](https://github.com/ppp0))

### 1.1.0

[View Diff](https://github.com/rodjek/puppet-lint/compare/1.0.1...1.1.0)

#### New features

 * puppet-lint configuration can now be set in the Rake task definition, so you
   no longer have to remember arcane `PuppetLint.configuration` options.
 * Multiple checks can now be disabled in a single control comment.
 * The performance of the parser has been significantly improved, most
   noticably when checking large manifest files.

#### Bug fixes

 * `unquoted_node_name` check now supports multiple node names in a comma
   separated list in a single `node` block.
 * `arrow_alignment` check now will now put parameters on their own line if it
   encounters a multiline resource with multiple parameters on a line.
 * `variable_scope` check no longer throws false positive results when using
   the automatically created variables from metaparameters.
 * `arrow_alignment` check no longer destroys the parameter name when it
   encounters a parameter followed by an arrow with no whitespace between them.
 * puppet-lint no longer parses the body of the class when searching for the
   parameter tokens of an unparameterised class.

---

### 1.0.1

[View Diff](https://github.com/rodjek/puppet-lint/compare/1.0.0...1.0.1)

#### Bug fixes

 * Fixed bug where array/hash access would cause a `top_scope_variable` false
   positive.
 * Fixed bug where `puppet-lint` would throw an exception when running the
   `arrow_alignment` check over a resource with more than one parameter and one
   of the parameters has an empty hash as its value.

---

### 1.0.0

[View Diff](https://github.com/rodjek/puppet-lint/compare/0.3.2...1.0.0)

#### New features

 * Support for using control comments to disable arbitrary tests.
 * Support for automatically fixing many common problems found with
   `puppet-lint`.
 * Added `puppet_url_without_modules` check to warn when `puppet://` URLs are
   used without the path starting with `modules/`.
 * Rake task now reads puppet-lint configuration from `puppet-lint.rc` files.
 * Added `unquoted_node_name` check to warn when unquoted `node` names are
   found.
 * Added `-c`/`--config` option to specify a custom path to `puppet-lint.rc`.
 * `puppet-lint` will now automatically add the filename to the output if
   multiple files are being linted.
 * Added support for the future parsers loop syntax.  Variables defined and
   used inside a loop-local scope will no longer throw `variable_scope`
   warnings.
 * Like URLs, long `template()` lines will no longer throw `80chars` warnings.
 * Added support to `puppet-lint` to specify certain checks to run, rather than
   having to disable all the checks but the desired ones.
 * The `arrow_alignment` check now throws a warning if the arrows aren't
   aligned as close to the parameter name as possible.
 * Added `--relative` flag which will have the `autoloader_layout` check ignore
   the top-most directory (good for cases where the module hosted publicly in
   a `puppet-<foo>` directory).

#### Removed features

 * Removed the `class_parameter_defaults` check.
 * `%{linenumber}` has been deprecated in the output format string and will be
   removed in the next major release.  You should use `%{line}` instead.

#### Bug fixes

 * Added support for more recognised escape characters (`\$`, `\"`, `\'`,
   `\r`) to the `double_quoted_strings` check.
 * Fixed bug where running with `--with-context` would occasionally throw a nil
   offset error.
 * Added support to the lexer for the modulo (`%`) character.
 * Fixed bug where a class or defined type argument with a default value of
   a Hash would throw a false `variable_scope` warning.
 * Fixed bug where auditing a `file` mode would throw false `file_mode`
   warning.
 * Fixed bug where line endings containing a carriage return (the default for
   most non Unix-like systems) would throw a syntax error.
 * Fixed bug where a double quoted string containing a single quoted string
   would throw a false `double_quoted_string` warning.
 * `puppet-lint` will no longer throw `only_variable_string` warnings when
   using quoted variables as Hash keys.
 * Rake task now exits cleanly when errors have been found.

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
