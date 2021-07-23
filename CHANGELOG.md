# Changelog

## [2.5.0](https://github.com/rodjek/puppet-lint/tree/2.5.0) (2021-07-21)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.4.2...2.5.0)

**Implemented enhancements:**

- Include check name in log output by default [\#883](https://github.com/rodjek/puppet-lint/pull/883) ([usev6](https://github.com/usev6))

**Fixed bugs:**

- Array operations on parameters confuse puppet-lint [\#930](https://github.com/rodjek/puppet-lint/issues/930)
- Wrong warrning: "variable contains an uppercase" [\#929](https://github.com/rodjek/puppet-lint/issues/929)
- Erroneous "WARNING: indentation of =\> is not properly aligned" since 2.4.0 [\#912](https://github.com/rodjek/puppet-lint/issues/912)
- NoMethodError: undefined method `next\_token\_of' for nil:NilClass [\#906](https://github.com/rodjek/puppet-lint/issues/906)
- Lint failure on reduce function [\#869](https://github.com/rodjek/puppet-lint/issues/869)
- lint failure on 'ensure' word in dsc\_lite module   [\#866](https://github.com/rodjek/puppet-lint/issues/866)
- Content of heredocs should not be checked [\#851](https://github.com/rodjek/puppet-lint/issues/851)
- Whoops! It looks like puppet-lint has encountered an error that it doesn't [\#839](https://github.com/rodjek/puppet-lint/issues/839)

**Closed issues:**

- heredoc prematurely terminated [\#940](https://github.com/rodjek/puppet-lint/issues/940)
- Heredoc syntax error [\#935](https://github.com/rodjek/puppet-lint/issues/935)
- Lint for ' [\#927](https://github.com/rodjek/puppet-lint/issues/927)
- puppet-lint-class\_parameter-check fails on voxpupuli/collectd [\#926](https://github.com/rodjek/puppet-lint/issues/926)
- puppet-lint error [\#917](https://github.com/rodjek/puppet-lint/issues/917)
- Improper "unquoted node name found" [\#904](https://github.com/rodjek/puppet-lint/issues/904)
- 2.4.x regression with puppet-lint-legacy\_facts-check [\#902](https://github.com/rodjek/puppet-lint/issues/902)
- puppet-lint a puppet type in voxpupuli-corosync [\#857](https://github.com/rodjek/puppet-lint/issues/857)
- Create and publish a docker image for puppet-lint [\#794](https://github.com/rodjek/puppet-lint/issues/794)

**Merged pull requests:**

- Select parameter tokens based on preceeding code token [\#934](https://github.com/rodjek/puppet-lint/pull/934) ([rodjek](https://github.com/rodjek))
- Move most CI to GH actions [\#933](https://github.com/rodjek/puppet-lint/pull/933) ([rodjek](https://github.com/rodjek))
- Correctly lex non-keyword type tokens in interpolation [\#932](https://github.com/rodjek/puppet-lint/pull/932) ([rodjek](https://github.com/rodjek))
- Disallow empty lines between docs and class/define [\#931](https://github.com/rodjek/puppet-lint/pull/931) ([ekohl](https://github.com/ekohl))
- Improve Rake task [\#919](https://github.com/rodjek/puppet-lint/pull/919) ([raphink](https://github.com/raphink))
- \(\#912\) Count consumed chars not bytes when slurping strings [\#915](https://github.com/rodjek/puppet-lint/pull/915) ([rodjek](https://github.com/rodjek))
- Do not rely on tokens array positioning when fixing ensure\_first\_param problems [\#914](https://github.com/rodjek/puppet-lint/pull/914) ([rodjek](https://github.com/rodjek))
- Only run test coverage once [\#913](https://github.com/rodjek/puppet-lint/pull/913) ([rodjek](https://github.com/rodjek))
- add MIT license to gemspec [\#910](https://github.com/rodjek/puppet-lint/pull/910) ([bastelfreak](https://github.com/bastelfreak))
- Improve spelling for some tests [\#909](https://github.com/rodjek/puppet-lint/pull/909) ([usev6](https://github.com/usev6))
- \(\#851\) Ensure heredoc ending tag is on its own line [\#903](https://github.com/rodjek/puppet-lint/pull/903) ([rodjek](https://github.com/rodjek))
- \(\#794\) Dockerfile for puppet-lint [\#901](https://github.com/rodjek/puppet-lint/pull/901) ([rodjek](https://github.com/rodjek))

## [2.4.2](https://github.com/rodjek/puppet-lint/tree/2.4.2) (2019-10-31)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.4.1...2.4.2)

**Fixed bugs:**

- `ERROR: Syntax error (unterminated string)` with 2.4.1 [\#899](https://github.com/rodjek/puppet-lint/issues/899)
- Double quoted string containing variable named "node" mis-tokenized [\#897](https://github.com/rodjek/puppet-lint/issues/897)
- 2.4.1 says Syntax error, but code runs fine [\#891](https://github.com/rodjek/puppet-lint/issues/891)
- Error with regex variable with multiple `|`s. [\#859](https://github.com/rodjek/puppet-lint/issues/859)

**Closed issues:**

- WARNING: double quoted string containing no variables [\#895](https://github.com/rodjek/puppet-lint/issues/895)

**Merged pull requests:**

- Fix regression in tokenization in double-quoted strings [\#898](https://github.com/rodjek/puppet-lint/pull/898) ([seanmil](https://github.com/seanmil))
- Speed up calculation of resource indexes [\#893](https://github.com/rodjek/puppet-lint/pull/893) ([usev6](https://github.com/usev6))
- Search end of string before assuming escaped quote [\#892](https://github.com/rodjek/puppet-lint/pull/892) ([usev6](https://github.com/usev6))
- Allow parsing of regexes as rvalues [\#882](https://github.com/rodjek/puppet-lint/pull/882) ([usev6](https://github.com/usev6))

## [2.4.1](https://github.com/rodjek/puppet-lint/tree/2.4.1) (2019-10-09)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.4.0...2.4.1)

**Fixed bugs:**

- Puppet-lint 2.4.0 throws misleading warning on double-quoted strings with escaped variables [\#886](https://github.com/rodjek/puppet-lint/issues/886)
- Puppet-lint 2.4.0 - ERROR: Syntax error on line x [\#887](https://github.com/rodjek/puppet-lint/issues/887)
- Breaks after 2.4.0 upgrade [\#885](https://github.com/rodjek/puppet-lint/issues/885)

**Merged pull requests:**

- Fix escaped ${} enclosure handling when slurping double quoted strings [\#889](https://github.com/rodjek/puppet-lint/pull/889) ([rodjek](https://github.com/rodjek))
- Fix non-indented heredoc parsing [\#888](https://github.com/rodjek/puppet-lint/pull/888) ([rodjek](https://github.com/rodjek))

## [2.4.0](https://github.com/rodjek/puppet-lint/tree/2.4.0) (2019-10-08)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.6...2.4.0)

**Fixed bugs:**

- Syntax error on Pattern data type [\#833](https://github.com/rodjek/puppet-lint/issues/833)
- Command line options do not override options from config files [\#879](https://github.com/rodjek/puppet-lint/issues/879)
- Fix for variables\_not\_enclosed incorrectly handles variables followed by a dash [\#836](https://github.com/rodjek/puppet-lint/issues/836)
- Error with puppet-lint --fix: NoMethodError: undefined method `next\_token' for nil:NilClass [\#831](https://github.com/rodjek/puppet-lint/issues/831)
- TypeError: no implicit conversion of nil into String [\#830](https://github.com/rodjek/puppet-lint/issues/830)
- Selector with 'default' case disables check for missing default in outer case statement [\#829](https://github.com/rodjek/puppet-lint/issues/829)
- undefined method `next\_token' for nil:NilClass [\#824](https://github.com/rodjek/puppet-lint/issues/824)
- NoMethodError: undefined method `next\_token' for nil:NilClass [\#790](https://github.com/rodjek/puppet-lint/issues/790)
- Puppet-lint --fix silently removes necessary $ inside double quoted strings [\#773](https://github.com/rodjek/puppet-lint/issues/773)
- It looks like puppet-lint has encountered an error that it doesn't know how to handle [\#768](https://github.com/rodjek/puppet-lint/issues/768)
- puppet-lint lexer string interpolation needs to be updated to match PUP-5887 changes [\#747](https://github.com/rodjek/puppet-lint/issues/747)
- Syntax error causes 'Whoops!' [\#740](https://github.com/rodjek/puppet-lint/issues/740)
- "quoted boolean value found" in hash value should not raise a warning. [\#474](https://github.com/rodjek/puppet-lint/issues/474)

**Closed issues:**

- Error when running puppet-lint [\#862](https://github.com/rodjek/puppet-lint/issues/862)
- puppet-lint crashes with mispelled namespace seperators [\#853](https://github.com/rodjek/puppet-lint/issues/853)
- NoMethodError: undefined method `prev\_token' for nil:NilClass [\#845](https://github.com/rodjek/puppet-lint/issues/845)
- Lint incorrectly errors on quoted bool [\#844](https://github.com/rodjek/puppet-lint/issues/844)
- Type\[\]\] raises NoMethodError [\#843](https://github.com/rodjek/puppet-lint/issues/843)
- Whoops! It looks like puppet-lint has encountered an error that it doesn't know how to handle. [\#842](https://github.com/rodjek/puppet-lint/issues/842)
- Whoops! It looks like puppet-lint has encountered an error that it doesn't [\#838](https://github.com/rodjek/puppet-lint/issues/838)
- Incorrectly wrapped hash variable inside double quotes [\#826](https://github.com/rodjek/puppet-lint/issues/826)
- Test puppet-lint against Ruby 2.5.x [\#818](https://github.com/rodjek/puppet-lint/issues/818)
- nested ensure misdetected as not coming first. [\#410](https://github.com/rodjek/puppet-lint/issues/410)

**Merged pull requests:**

- README - Add GitHub Actions action [\#868](https://github.com/rodjek/puppet-lint/pull/868) ([ScottBrenner](https://github.com/ScottBrenner))
- Update TravisCI config to use trusty image [\#867](https://github.com/rodjek/puppet-lint/pull/867) ([rodjek](https://github.com/rodjek))
- Use the default travis rubygems & bundler [\#860](https://github.com/rodjek/puppet-lint/pull/860) ([rodjek](https://github.com/rodjek))
- Add `Sensitive` to the list of KNOWN\_TOKEN TYPES [\#858](https://github.com/rodjek/puppet-lint/pull/858) ([alexjfisher](https://github.com/alexjfisher))
- Avoid internal error for typoed namespace [\#855](https://github.com/rodjek/puppet-lint/pull/855) ([usev6](https://github.com/usev6))
- Use lookahead assertion for matching function name [\#854](https://github.com/rodjek/puppet-lint/pull/854) ([usev6](https://github.com/usev6))
- Resource: fix nested ensure error. [\#848](https://github.com/rodjek/puppet-lint/pull/848) ([keur](https://github.com/keur))
- Rewrite double quoted string handling for nested interpolation [\#846](https://github.com/rodjek/puppet-lint/pull/846) ([rodjek](https://github.com/rodjek))
- Allow for spaces in the heredoc tag [\#841](https://github.com/rodjek/puppet-lint/pull/841) ([jarretlavallee](https://github.com/jarretlavallee))
- Recognizes multiline regexes [\#835](https://github.com/rodjek/puppet-lint/pull/835) ([jcbollinger](https://github.com/jcbollinger))
- Handle unenclosed variables followed by dashes when fixing [\#881](https://github.com/rodjek/puppet-lint/pull/881) ([rodjek](https://github.com/rodjek))
- Let command line args override config from files [\#880](https://github.com/rodjek/puppet-lint/pull/880) ([usev6](https://github.com/usev6))
- Ignore hash keys when checking resource parameter order [\#877](https://github.com/rodjek/puppet-lint/pull/877) ([rodjek](https://github.com/rodjek))
- Only look for 'default' at first level of 'case' statement [\#876](https://github.com/rodjek/puppet-lint/pull/876) ([usev6](https://github.com/usev6))
- Report syntax error on unbalanced braces [\#875](https://github.com/rodjek/puppet-lint/pull/875) ([rodjek](https://github.com/rodjek))
- Include hash/array references when enclosing variables [\#874](https://github.com/rodjek/puppet-lint/pull/874) ([rodjek](https://github.com/rodjek))
- Disable quoted\_booleans check by default [\#873](https://github.com/rodjek/puppet-lint/pull/873) ([rodjek](https://github.com/rodjek))
- Test against Ruby 2.5 & 2.6 [\#872](https://github.com/rodjek/puppet-lint/pull/872) ([rodjek](https://github.com/rodjek))

## [2.3.6](https://github.com/rodjek/puppet-lint/tree/2.3.6) (2018-07-09)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.5...2.3.6)

**Fixed bugs:**

- --fix does not work with require arrows in certain situations [\#799](https://github.com/rodjek/puppet-lint/issues/799)
- Error with --fix when no whitespace before hashrocket in resource attribute list [\#798](https://github.com/rodjek/puppet-lint/issues/798)
- puppet-lint --fix strips comments when fixing arrow\_on\_right\_operand\_line [\#792](https://github.com/rodjek/puppet-lint/issues/792)
- Crash report, reason unclear [\#781](https://github.com/rodjek/puppet-lint/issues/781)
- crash in fix mode with multiple trailing arrows [\#776](https://github.com/rodjek/puppet-lint/issues/776)
- Error negative argument if opening brace on the same line and following element longer [\#771](https://github.com/rodjek/puppet-lint/issues/771)
- ArgumentError: negative argument [\#723](https://github.com/rodjek/puppet-lint/issues/723)

**Merged pull requests:**

- \(\#771\) Handle arrow alignment when arrow column \< opening brace column... [\#819](https://github.com/rodjek/puppet-lint/pull/819) ([rodjek](https://github.com/rodjek))
- Less aggressive fix method for arrow\_on\_right\_operand\_line [\#817](https://github.com/rodjek/puppet-lint/pull/817) ([rodjek](https://github.com/rodjek))
- Check if token still exists before fixing trailing\_whitespace [\#816](https://github.com/rodjek/puppet-lint/pull/816) ([rodjek](https://github.com/rodjek))
- Run all the checks before fixing problems [\#815](https://github.com/rodjek/puppet-lint/pull/815) ([rodjek](https://github.com/rodjek))

## [2.3.5](https://github.com/rodjek/puppet-lint/tree/2.3.5) (2018-03-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.4...2.3.5)

**Fixed bugs:**

- v2.3.4 breakage - 'wrong number of arguments' when using Rake task [\#812](https://github.com/rodjek/puppet-lint/issues/812)

**Merged pull requests:**

- Make PuppetLint::OptParser.build argument optional [\#813](https://github.com/rodjek/puppet-lint/pull/813) ([rodjek](https://github.com/rodjek))

## [2.3.4](https://github.com/rodjek/puppet-lint/tree/2.3.4) (2018-03-26)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.3...2.3.4)

**Implemented enhancements:**

- Allow ignoring default configurations files on the command line [\#787](https://github.com/rodjek/puppet-lint/issues/787)
- Implement --list-checks feature, to list the names of all available checks from the cli. [\#804](https://github.com/rodjek/puppet-lint/pull/804) ([xraystyle](https://github.com/xraystyle))
- Option to disable loading default configurations files [\#789](https://github.com/rodjek/puppet-lint/pull/789) ([dioni21](https://github.com/dioni21))
- Allow passing ignore\_paths from cli [\#783](https://github.com/rodjek/puppet-lint/pull/783) ([keymone](https://github.com/keymone))

**Fixed bugs:**

- Bad value for range [\#801](https://github.com/rodjek/puppet-lint/issues/801)
- puppet-lint doesn't handle CRLFs very well [\#778](https://github.com/rodjek/puppet-lint/issues/778)
- Configuration's ignore\_paths is not respected [\#774](https://github.com/rodjek/puppet-lint/issues/774)
- Error when including class and missing a colon [\#507](https://github.com/rodjek/puppet-lint/issues/507)

**Merged pull requests:**

- Handle single colon in resource name syntax error [\#809](https://github.com/rodjek/puppet-lint/pull/809) ([rodjek](https://github.com/rodjek))
- \(\#778\) Don't include line ending in single line comment token values [\#782](https://github.com/rodjek/puppet-lint/pull/782) ([rodjek](https://github.com/rodjek))
- Fix setting ignore\_paths in Rake task [\#777](https://github.com/rodjek/puppet-lint/pull/777) ([alzabo](https://github.com/alzabo))
- Add support for passing backslash separated paths to puppet-lint [\#769](https://github.com/rodjek/puppet-lint/pull/769) ([rodjek](https://github.com/rodjek))

## [2.3.3](https://github.com/rodjek/puppet-lint/tree/2.3.3) (2017-09-28)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.2...2.3.3)

**Closed issues:**

- 2.3.2 - Rakefile's ignore\_paths not respected [\#760](https://github.com/rodjek/puppet-lint/issues/760)
- 2.3.1 - Puppet lint fails with 1.8.7-p371 and Puppet 3.8.0 [\#759](https://github.com/rodjek/puppet-lint/issues/759)

**Merged pull requests:**

- Add some basic acceptance tests [\#764](https://github.com/rodjek/puppet-lint/pull/764) ([rodjek](https://github.com/rodjek))
- Change acceptance tests to work with Ruby 1.8.7 [\#767](https://github.com/rodjek/puppet-lint/pull/767) ([rodjek](https://github.com/rodjek))
- Restore Ruby 1.8.7 support [\#763](https://github.com/rodjek/puppet-lint/pull/763) ([rodjek](https://github.com/rodjek))
- Don't override ignore\_paths set in rake task with default value [\#762](https://github.com/rodjek/puppet-lint/pull/762) ([rodjek](https://github.com/rodjek))
- Add spec for issue raised in \#754 \#756 [\#761](https://github.com/rodjek/puppet-lint/pull/761) ([rodjek](https://github.com/rodjek))
- Fix setup of default log\_format in PuppetLink.configuration when it is empty. [\#757](https://github.com/rodjek/puppet-lint/pull/757) ([zekefast](https://github.com/zekefast))

## [2.3.2](https://github.com/rodjek/puppet-lint/tree/2.3.2) (2017-09-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.1...2.3.2)

**Closed issues:**

- rake task now failing [\#754](https://github.com/rodjek/puppet-lint/issues/754)

**Merged pull requests:**

- 2.3.2 release [\#758](https://github.com/rodjek/puppet-lint/pull/758) ([tphoney](https://github.com/tphoney))
- fix logic in method\_missing [\#755](https://github.com/rodjek/puppet-lint/pull/755) ([tphoney](https://github.com/tphoney))

## [2.3.1](https://github.com/rodjek/puppet-lint/tree/2.3.1) (2017-09-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.3.0...2.3.1)

**Fixed bugs:**

- `incompatible encoding regexp match` for non-printing characters in place of space [\#693](https://github.com/rodjek/puppet-lint/issues/693)
- Unhandled error case [\#691](https://github.com/rodjek/puppet-lint/issues/691)
- NoMethodError: undefined method `type' for nil:NilClass [\#732](https://github.com/rodjek/puppet-lint/issues/732)
- NoMethodError: undefined method `end\_with?' for nil:NilClass [\#727](https://github.com/rodjek/puppet-lint/issues/727)
- puppet-lint not applying some lint:ignore statements when there are more then 2 on the same line [\#726](https://github.com/rodjek/puppet-lint/issues/726)
- optional paramter warning false positve when inheriting params [\#716](https://github.com/rodjek/puppet-lint/issues/716)
- invalid byte sequence in UTF-8 in selmodule-example.pp [\#714](https://github.com/rodjek/puppet-lint/issues/714)
- puppet-lint --fix encountered an error that it doesn't know how to handle [\#706](https://github.com/rodjek/puppet-lint/issues/706)
- Mangled file after running puppet-lint due to chained function call [\#703](https://github.com/rodjek/puppet-lint/issues/703)

**Closed issues:**

- puppet-lint has encountered an error that it doesn't know how to handle [\#750](https://github.com/rodjek/puppet-lint/issues/750)
- Puppet lint syntax error - puppet parser validate no issues [\#746](https://github.com/rodjek/puppet-lint/issues/746)
- Whoops, not sure why. ArgumentError: bad value for range [\#742](https://github.com/rodjek/puppet-lint/issues/742)
- ArgumentError: bad value for range [\#741](https://github.com/rodjek/puppet-lint/issues/741)
- Whoops! It looks like puppet-lint has encountered an error [\#729](https://github.com/rodjek/puppet-lint/issues/729)
- puppet lint config log\_format not working [\#725](https://github.com/rodjek/puppet-lint/issues/725)
- Chaining arrow syntax fix introduces trailing whitespaces [\#695](https://github.com/rodjek/puppet-lint/issues/695)
- Refactor check\_comments.rb [\#587](https://github.com/rodjek/puppet-lint/issues/587)
- Puppethack 12/2016 Issues [\#583](https://github.com/rodjek/puppet-lint/issues/583)
- Allow multiple block-level ignore comments [\#498](https://github.com/rodjek/puppet-lint/issues/498)
- puppet-lint crashes with "invalid byte sequence in UTF-8 \(ArgumentError\)" [\#458](https://github.com/rodjek/puppet-lint/issues/458)
- Variable use like "a+1 = ${$a + 1}" isn't reported but silently changed by --fix to "a+1 = ${a} + 1" [\#749](https://github.com/rodjek/puppet-lint/issues/749)
- using --fix changes line endings [\#748](https://github.com/rodjek/puppet-lint/issues/748)
- Error not handled [\#745](https://github.com/rodjek/puppet-lint/issues/745)
- Line numbers off after multi-line strings with variables [\#736](https://github.com/rodjek/puppet-lint/issues/736)
- Quoted booleans in Puppet5 for Enum type declarations. [\#720](https://github.com/rodjek/puppet-lint/issues/720)
- Plugins reorganization: One file per check [\#657](https://github.com/rodjek/puppet-lint/issues/657)

**Merged pull requests:**

- Remove monkeypatches to implement String\#% [\#744](https://github.com/rodjek/puppet-lint/pull/744) ([rodjek](https://github.com/rodjek))
- Add unit tests for PuppetLint::Checks [\#743](https://github.com/rodjek/puppet-lint/pull/743) ([rodjek](https://github.com/rodjek))
- Update CI configuration [\#739](https://github.com/rodjek/puppet-lint/pull/739) ([rodjek](https://github.com/rodjek))
- Rubocop compliance [\#738](https://github.com/rodjek/puppet-lint/pull/738) ([rodjek](https://github.com/rodjek))
- Fix line numbers being off with multi-line strings containing variables [\#737](https://github.com/rodjek/puppet-lint/pull/737) ([cbowman0](https://github.com/cbowman0))
- Split control comments into words before parsing [\#735](https://github.com/rodjek/puppet-lint/pull/735) ([rodjek](https://github.com/rodjek))
- Handle unicode spaces in the tokeniser [\#734](https://github.com/rodjek/puppet-lint/pull/734) ([rodjek](https://github.com/rodjek))
- Handle SE Linux policy package files [\#733](https://github.com/rodjek/puppet-lint/pull/733) ([rodjek](https://github.com/rodjek))
- Chaining arrow syntax fix introduces trailing whitespaces [\#708](https://github.com/rodjek/puppet-lint/pull/708) ([rnelson0](https://github.com/rnelson0))
- Plugins: Improve code readability [\#658](https://github.com/rodjek/puppet-lint/pull/658) ([Darhazer](https://github.com/Darhazer))
- Render the ${} enclosures as part of the string tokens [\#752](https://github.com/rodjek/puppet-lint/pull/752) ([rodjek](https://github.com/rodjek))
- Open manifest as binary when writing fixed manifest [\#751](https://github.com/rodjek/puppet-lint/pull/751) ([rodjek](https://github.com/rodjek))
- Take into account Optional data type when checking parameter order [\#731](https://github.com/rodjek/puppet-lint/pull/731) ([rodjek](https://github.com/rodjek))
- Read the manifest files as UTF-8 [\#730](https://github.com/rodjek/puppet-lint/pull/730) ([rodjek](https://github.com/rodjek))
- Improve handling of unterminated double quoted strings [\#728](https://github.com/rodjek/puppet-lint/pull/728) ([rodjek](https://github.com/rodjek))
- Add helper methods to add and remove tokens while maintaining the token links [\#694](https://github.com/rodjek/puppet-lint/pull/694) ([Darhazer](https://github.com/Darhazer))
- Check that arrow is on the line of right operand [\#672](https://github.com/rodjek/puppet-lint/pull/672) ([Darhazer](https://github.com/Darhazer))
- One file per plugin. Fixes \#657 [\#671](https://github.com/rodjek/puppet-lint/pull/671) ([Darhazer](https://github.com/Darhazer))
- Code style improvements [\#661](https://github.com/rodjek/puppet-lint/pull/661) ([Darhazer](https://github.com/Darhazer))

## [2.3.0](https://github.com/rodjek/puppet-lint/tree/2.3.0) (2017-07-12)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.2.1...2.3.0)

**Closed issues:**

- Inappropriate =\> Indentation Warning in Hash [\#698](https://github.com/rodjek/puppet-lint/issues/698)
- Regression: arrow\_alignment check broken between 2.1.1 and 2.2.x releases when left side contains text after variable interpolation [\#697](https://github.com/rodjek/puppet-lint/issues/697)
- Check `arrow_on_right_operand_line` is undocumented. [\#688](https://github.com/rodjek/puppet-lint/issues/688)

**Merged pull requests:**

- \(maint\) Fixes puppet-lint json formatting to output valid json to stdout [\#719](https://github.com/rodjek/puppet-lint/pull/719) ([bmjen](https://github.com/bmjen))
- Permit puppet-lint to load "prerelease" gems [\#718](https://github.com/rodjek/puppet-lint/pull/718) ([kpaulisse](https://github.com/kpaulisse))
- Document the configuration file better [\#713](https://github.com/rodjek/puppet-lint/pull/713) ([binford2k](https://github.com/binford2k))
- Readme formatting fixes [\#709](https://github.com/rodjek/puppet-lint/pull/709) ([dbeckham](https://github.com/dbeckham))
- Readme edit [\#707](https://github.com/rodjek/puppet-lint/pull/707) ([jbondpdx](https://github.com/jbondpdx))
- Take into account length of DQPOST token when updating column number [\#701](https://github.com/rodjek/puppet-lint/pull/701) ([dbeckham](https://github.com/dbeckham))
- Add pattern support to rake task [\#700](https://github.com/rodjek/puppet-lint/pull/700) ([dbeckham](https://github.com/dbeckham))
- Note arrow\_on\_right\_operand\_line in the README [\#690](https://github.com/rodjek/puppet-lint/pull/690) ([rodjek](https://github.com/rodjek))

## [2.2.1](https://github.com/rodjek/puppet-lint/tree/2.2.1) (2017-03-29)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.2.0...2.2.1)

**Closed issues:**

- Error on whitespace with 2.2.0 [\#683](https://github.com/rodjek/puppet-lint/issues/683)
- "undefined method `map' for nil:NilClass" when running check\_whitespace [\#681](https://github.com/rodjek/puppet-lint/issues/681)
- "undefined method `next\_token='" when fixing with check\_whitespace [\#680](https://github.com/rodjek/puppet-lint/issues/680)
- Release 2.2.0 planning and discussion [\#668](https://github.com/rodjek/puppet-lint/issues/668)

**Merged pull requests:**

- restore the links between tokens after arrow\_on\_right\_operand\_line\#fix [\#684](https://github.com/rodjek/puppet-lint/pull/684) ([rodjek](https://github.com/rodjek))
- level\_tokens\[0\] can be nil if there is no params in the top level block [\#682](https://github.com/rodjek/puppet-lint/pull/682) ([rodjek](https://github.com/rodjek))

## [2.2.0](https://github.com/rodjek/puppet-lint/tree/2.2.0) (2017-03-29)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.1.1...2.2.0)

**Closed issues:**

- 2.1.1 git tag [\#652](https://github.com/rodjek/puppet-lint/issues/652)
- Quoted boolean triggers on the command 'true' [\#646](https://github.com/rodjek/puppet-lint/issues/646)
- Namevars detected as optional parameters [\#633](https://github.com/rodjek/puppet-lint/issues/633)
- 'Duplicate Parameter' warning on dynamic class parameter [\#627](https://github.com/rodjek/puppet-lint/issues/627)
- arrow\_alignment should only check the alignment of the first arrow on each line [\#609](https://github.com/rodjek/puppet-lint/issues/609)
- Top-scope variable warning on inline lambda [\#549](https://github.com/rodjek/puppet-lint/issues/549)
- Puppet-lint crash with new puppet 4 syntax [\#516](https://github.com/rodjek/puppet-lint/issues/516)
- Top-scope warning when looping though an array of hashes [\#464](https://github.com/rodjek/puppet-lint/issues/464)
- Array of hashes one-liner throws a "Indentation of =\> is not properly aligned" [\#446](https://github.com/rodjek/puppet-lint/issues/446)
- Missed bad file modes in file with multiple resource bodies [\#663](https://github.com/rodjek/puppet-lint/issues/663)
- Provide helper methods to search for specific tokens [\#660](https://github.com/rodjek/puppet-lint/issues/660)
- ensure\_first\_param fix can create invalid syntax [\#659](https://github.com/rodjek/puppet-lint/issues/659)
- puppet-lint dies with inline\_template syntax [\#656](https://github.com/rodjek/puppet-lint/issues/656)
- Variable use like "${$a}" isn't reported as an error and is changed with no message when run with --fix [\#655](https://github.com/rodjek/puppet-lint/issues/655)
- Linter gets confused with arrays of hashes [\#654](https://github.com/rodjek/puppet-lint/issues/654)
- heredoc throws unhandled exception [\#649](https://github.com/rodjek/puppet-lint/issues/649)
- Match function breaks puppet-lint [\#645](https://github.com/rodjek/puppet-lint/issues/645)
- top-scope variable being used without an explicit namespace in a string with a lookup [\#635](https://github.com/rodjek/puppet-lint/issues/635)
- unquoted file mode & mode should be represented as a 4 digit when file mode is done by a lookup [\#634](https://github.com/rodjek/puppet-lint/issues/634)
- double\_quoted\_strings-check issue with escaped character in the string [\#625](https://github.com/rodjek/puppet-lint/issues/625)
- unable to disable 140chars check with control comments "block" [\#622](https://github.com/rodjek/puppet-lint/issues/622)
- unquoted\_node\_name crash when curly braces missing [\#582](https://github.com/rodjek/puppet-lint/issues/582)
- Heredoc triggers exception in arrow\_alignment check [\#578](https://github.com/rodjek/puppet-lint/issues/578)
- Each + With = Fake positive top-scope variable detection [\#576](https://github.com/rodjek/puppet-lint/issues/576)
- Top-scope variable warning on nested each loops [\#548](https://github.com/rodjek/puppet-lint/issues/548)
- `arrow_alignment --fix` doesn't indent keys when introducing line breaks; erroneously reports success [\#506](https://github.com/rodjek/puppet-lint/issues/506)
- heredoc escape gives syntax error [\#430](https://github.com/rodjek/puppet-lint/issues/430)
- NoMethodError when multiple heredocs are used [\#395](https://github.com/rodjek/puppet-lint/issues/395)

**Merged pull requests:**

- Support double quoted strings inside interpolated values in double quoted strings [\#676](https://github.com/rodjek/puppet-lint/pull/676) ([rodjek](https://github.com/rodjek))
- Deal with ruby 1.8.7 gem issues [\#630](https://github.com/rodjek/puppet-lint/pull/630) ([mterzo](https://github.com/mterzo))
- Ignore selectors when finding resource type [\#678](https://github.com/rodjek/puppet-lint/pull/678) ([rodjek](https://github.com/rodjek))
- Fix for arrow\_alignment bugs in \#506 [\#677](https://github.com/rodjek/puppet-lint/pull/677) ([rodjek](https://github.com/rodjek))
- Don't silently remove unnecessary $ from enclosed variables [\#674](https://github.com/rodjek/puppet-lint/pull/674) ([rodjek](https://github.com/rodjek))
- Fix ensure\_first\_param fix method to retrieve the full value of the ensure parameter [\#673](https://github.com/rodjek/puppet-lint/pull/673) ([rodjek](https://github.com/rodjek))
- Restrict appveyor testing to Ruby versions that appveyor supports [\#670](https://github.com/rodjek/puppet-lint/pull/670) ([james-stocks](https://github.com/james-stocks))
- Clear expected parameter column after processing each block when checking arrow alignment [\#669](https://github.com/rodjek/puppet-lint/pull/669) ([rodjek](https://github.com/rodjek))
- Allow regexps to used as function arguments [\#665](https://github.com/rodjek/puppet-lint/pull/665) ([rodjek](https://github.com/rodjek))
- Catch unhandled exception and provide debug info for issue [\#664](https://github.com/rodjek/puppet-lint/pull/664) ([rodjek](https://github.com/rodjek))
- Fix showing of a failure [\#662](https://github.com/rodjek/puppet-lint/pull/662) ([Darhazer](https://github.com/Darhazer))
- \(SDK-115\) Enable appveyor testing [\#653](https://github.com/rodjek/puppet-lint/pull/653) ([james-stocks](https://github.com/james-stocks))
- Heredoc support [\#650](https://github.com/rodjek/puppet-lint/pull/650) ([rodjek](https://github.com/rodjek))
- Warn when control comment blocks are not properly terminated [\#648](https://github.com/rodjek/puppet-lint/pull/648) ([rodjek](https://github.com/rodjek))
- Prevent incomplete node blocks from crashing puppet-lint [\#642](https://github.com/rodjek/puppet-lint/pull/642) ([rodjek](https://github.com/rodjek))
- Update the tokeniser to differentiate between unquoted strings and function names [\#640](https://github.com/rodjek/puppet-lint/pull/640) ([rodjek](https://github.com/rodjek))
- Check for escaped backslashes too [\#639](https://github.com/rodjek/puppet-lint/pull/639) ([binford2k](https://github.com/binford2k))
- Correctly handle function calls inside string interpolation [\#638](https://github.com/rodjek/puppet-lint/pull/638) ([hanazuki](https://github.com/hanazuki))
- Correctly handle nested lambdas [\#637](https://github.com/rodjek/puppet-lint/pull/637) ([hanazuki](https://github.com/hanazuki))
- Support for nested multiple-variable assignments [\#636](https://github.com/rodjek/puppet-lint/pull/636) ([hanazuki](https://github.com/hanazuki))
- Add LoadError to fix broken tests [\#631](https://github.com/rodjek/puppet-lint/pull/631) ([davidmogar](https://github.com/davidmogar))

## [2.1.1](https://github.com/rodjek/puppet-lint/tree/2.1.1) (2017-02-15)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.1.0...2.1.1)

**Closed issues:**

- False positive detection in double quoted string containing no variables [\#618](https://github.com/rodjek/puppet-lint/issues/618)
- Warning and error classification [\#614](https://github.com/rodjek/puppet-lint/issues/614)
- Top-scope with multiple assignment using split [\#550](https://github.com/rodjek/puppet-lint/issues/550)
- Strange error about indent with comments [\#475](https://github.com/rodjek/puppet-lint/issues/475)
- Hash of hashes with long keys causes irrational warnings and crashes --fix [\#424](https://github.com/rodjek/puppet-lint/issues/424)
- Wrong arrow alignment when key has interpolated variable [\#416](https://github.com/rodjek/puppet-lint/issues/416)
- indentation of =\> is not properly aligned in hash within array [\#333](https://github.com/rodjek/puppet-lint/issues/333)

**Merged pull requests:**

- Correctly handle strings-with-variables as hash keys in arrow\_alignment check [\#621](https://github.com/rodjek/puppet-lint/pull/621) ([rodjek](https://github.com/rodjek))
- Support array of variables on left side of an assign operation [\#617](https://github.com/rodjek/puppet-lint/pull/617) ([rodjek](https://github.com/rodjek))
- Test against Ruby 2.4.0 [\#616](https://github.com/rodjek/puppet-lint/pull/616) ([rodjek](https://github.com/rodjek))
- Calculate arrow column from first parameter position, not the start of the line [\#615](https://github.com/rodjek/puppet-lint/pull/615) ([rodjek](https://github.com/rodjek))
- Do not test against Ruby 2.2 [\#613](https://github.com/rodjek/puppet-lint/pull/613) ([ghoneycutt](https://github.com/ghoneycutt))

## [2.1.0](https://github.com/rodjek/puppet-lint/tree/2.1.0) (2016-12-30)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.0.2...2.1.0)

**Closed issues:**

- Excessive number of warnings from code\_on\_top\_scope [\#579](https://github.com/rodjek/puppet-lint/issues/579)
- Syntax error for references starting with Regexp [\#566](https://github.com/rodjek/puppet-lint/issues/566)
- Module names must only contain lowercase letters [\#554](https://github.com/rodjek/puppet-lint/issues/554)
- Remove formatting with `linenumber` [\#539](https://github.com/rodjek/puppet-lint/issues/539)
- names\_containing\_dash is broken and unignorable [\#534](https://github.com/rodjek/puppet-lint/issues/534)
- Puppet-lint 2.0 fails on unquoted string starting with underscore. [\#531](https://github.com/rodjek/puppet-lint/issues/531)
- puppet-lint reports incorrect line numbers [\#403](https://github.com/rodjek/puppet-lint/issues/403)
- Release version 2.1.0 [\#610](https://github.com/rodjek/puppet-lint/issues/610)
- incorrect error on inline template [\#545](https://github.com/rodjek/puppet-lint/issues/545)
- parameter\_order check does not work default hash is added in parameter [\#544](https://github.com/rodjek/puppet-lint/issues/544)
- Incorrect warning of required parameter when using array that includes variable. [\#537](https://github.com/rodjek/puppet-lint/issues/537)
- syntax error on valid file when: if /regex/ in array [\#517](https://github.com/rodjek/puppet-lint/issues/517)
- crashes if there is a \# line:endignore with no begining. [\#509](https://github.com/rodjek/puppet-lint/issues/509)
- Wrong behaviour of variable\_contains\_dash [\#504](https://github.com/rodjek/puppet-lint/issues/504)
- Start a CHANGELOG, make updates part of the build workflow [\#479](https://github.com/rodjek/puppet-lint/issues/479)
- Nested future scope blocks lose local variables from parent scopes. [\#456](https://github.com/rodjek/puppet-lint/issues/456)
- block-local variables \(|$x|\) don't properly get recognized when used as arrays or hashes [\#450](https://github.com/rodjek/puppet-lint/issues/450)

**Merged pull requests:**

- Ignore \*.pp files at the top level [\#597](https://github.com/rodjek/puppet-lint/pull/597) ([rnelson0](https://github.com/rnelson0))
- Show logs in rspec tests [\#596](https://github.com/rodjek/puppet-lint/pull/596) ([ghoneycutt](https://github.com/ghoneycutt))
- Count lines in comments and double quoted strings [\#577](https://github.com/rodjek/puppet-lint/pull/577) ([paran1](https://github.com/paran1))
- Handle mismatched control comments gracefully [\#573](https://github.com/rodjek/puppet-lint/pull/573) ([rodjek](https://github.com/rodjek))
- Reimplementation of --fix support for unenclosed variables delimited by dashes [\#572](https://github.com/rodjek/puppet-lint/pull/572) ([rodjek](https://github.com/rodjek))
- Anchor the end of the :TYPE token regexp [\#571](https://github.com/rodjek/puppet-lint/pull/571) ([rodjek](https://github.com/rodjek))
- Multi line strings [\#570](https://github.com/rodjek/puppet-lint/pull/570) ([jiuka](https://github.com/jiuka))
- @node\_indexes should be reset too. [\#569](https://github.com/rodjek/puppet-lint/pull/569) ([jiuka](https://github.com/jiuka))
- True up reserved keywords [\#564](https://github.com/rodjek/puppet-lint/pull/564) ([rnelson0](https://github.com/rnelson0))
- Implement a linter for uppercase class names [\#558](https://github.com/rodjek/puppet-lint/pull/558) ([arrdem](https://github.com/arrdem))
- Include --fix usage instructions [\#557](https://github.com/rodjek/puppet-lint/pull/557) ([QuinnyPig](https://github.com/QuinnyPig))
- Updates PR for \#223 [\#552](https://github.com/rodjek/puppet-lint/pull/552) ([binford2k](https://github.com/binford2k))
- Remove formatting with `linenumber` [\#540](https://github.com/rodjek/puppet-lint/pull/540) ([rski](https://github.com/rski))
- Potential README changes [\#420](https://github.com/rodjek/puppet-lint/pull/420) ([rothsa](https://github.com/rothsa))
- Add fix to "ensure found on line but it's not the first attribute" [\#375](https://github.com/rodjek/puppet-lint/pull/375) ([sathieu](https://github.com/sathieu))
- Checks for code outside class/define block [\#223](https://github.com/rodjek/puppet-lint/pull/223) ([dLobatog](https://github.com/dLobatog))
- \(\#369\) Document existence of control comments [\#600](https://github.com/rodjek/puppet-lint/pull/600) ([rnelson0](https://github.com/rnelson0))
- \(\#517\) Update the allowed tokens prior to a regex [\#594](https://github.com/rodjek/puppet-lint/pull/594) ([rnelson0](https://github.com/rnelson0))
- \(\#531\) Treat barewords beginning with an underscore as :NAME tokens [\#593](https://github.com/rodjek/puppet-lint/pull/593) ([rnelson0](https://github.com/rnelson0))
- \(\#544, \#537\) Skip hash contents when checking optional parameters [\#592](https://github.com/rodjek/puppet-lint/pull/592) ([rnelson0](https://github.com/rnelson0))
- \(\#545\) Exempt inline\_epp and inline\_template from single quoted strin… [\#591](https://github.com/rodjek/puppet-lint/pull/591) ([rnelson0](https://github.com/rnelson0))
- Disable code\_on\_top\_scope by default until the noise can be reduced \(… [\#590](https://github.com/rodjek/puppet-lint/pull/590) ([rnelson0](https://github.com/rnelson0))
- Changelog generator task [\#589](https://github.com/rodjek/puppet-lint/pull/589) ([rnelson0](https://github.com/rnelson0))
- Adding support for logging to STDOUT as JSON [\#487](https://github.com/rodjek/puppet-lint/pull/487) ([binford2k](https://github.com/binford2k))

## [2.0.2](https://github.com/rodjek/puppet-lint/tree/2.0.2) (2016-08-19)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.0.1...2.0.2)

**Implemented enhancements:**

- Option to choose version of the puppet style guide [\#190](https://github.com/rodjek/puppet-lint/issues/190)

**Merged pull requests:**

- Revert "Bugfix: properly handling $gronk-$grouik with --fix \(fix \#442\)" [\#535](https://github.com/rodjek/puppet-lint/pull/535) ([rnelson0](https://github.com/rnelson0))

## [2.0.1](https://github.com/rodjek/puppet-lint/tree/2.0.1) (2016-08-18)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2.0.0...2.0.1)

**Implemented enhancements:**

- Allow specifying the default enable status of a check [\#484](https://github.com/rodjek/puppet-lint/issues/484)

**Closed issues:**

- Changelog on Github pages is out of date [\#520](https://github.com/rodjek/puppet-lint/issues/520)
- 80char --\> 140char transition incomplete [\#514](https://github.com/rodjek/puppet-lint/issues/514)
- ensure\_first\_param-check should not consider hashes [\#512](https://github.com/rodjek/puppet-lint/issues/512)
- RFE: Provide a way to selectively disable checks in puppet source [\#508](https://github.com/rodjek/puppet-lint/issues/508)
- question: 1.1.0 --\> 2.0.0 new checks [\#499](https://github.com/rodjek/puppet-lint/issues/499)
- \[\#puppethack\] disable\_char\_check doesn't work [\#493](https://github.com/rodjek/puppet-lint/issues/493)
- Error fixing indent in possion 0 [\#489](https://github.com/rodjek/puppet-lint/issues/489)
- Empty lines with trailing whitespace triggers redundant soft tabs error. [\#478](https://github.com/rodjek/puppet-lint/issues/478)
- Little problem with =\> when variables are used as key [\#472](https://github.com/rodjek/puppet-lint/issues/472)
- Question: using config file, with custom path [\#466](https://github.com/rodjek/puppet-lint/issues/466)
- Error: "Variable in single quoted string" or "Double quoted string without variable" - syntax? [\#463](https://github.com/rodjek/puppet-lint/issues/463)
- Critical error on Atom initialization [\#460](https://github.com/rodjek/puppet-lint/issues/460)
- print warning for code that will result in logging or backups of secrets [\#455](https://github.com/rodjek/puppet-lint/issues/455)
- Linter gets upset with Regexp in type [\#452](https://github.com/rodjek/puppet-lint/issues/452)
- Single whitespace in file replaced with \[\] [\#444](https://github.com/rodjek/puppet-lint/issues/444)
- Time for a new release! [\#443](https://github.com/rodjek/puppet-lint/issues/443)
- Bug with --fix and warning "variable not enclosed in {}" [\#442](https://github.com/rodjek/puppet-lint/issues/442)
- Linter should not warn about inheriting from params class [\#441](https://github.com/rodjek/puppet-lint/issues/441)
- Variable not enclosed in {} AND single quoted string containing a variable [\#434](https://github.com/rodjek/puppet-lint/issues/434)
- Quoted string issue due to structured data [\#433](https://github.com/rodjek/puppet-lint/issues/433)
- allow for arrow alignment with more than one space before [\#432](https://github.com/rodjek/puppet-lint/issues/432)
- 3 digit modes are incorrectly flagged [\#431](https://github.com/rodjek/puppet-lint/issues/431)
- url\_without\_modules adding paths? [\#428](https://github.com/rodjek/puppet-lint/issues/428)
- Check for unbalanced parenthesis [\#427](https://github.com/rodjek/puppet-lint/issues/427)
- puppet-lint crash [\#422](https://github.com/rodjek/puppet-lint/issues/422)
- PuppetLint.configuration.ignore\_paths ignored by puppet-lint [\#417](https://github.com/rodjek/puppet-lint/issues/417)
- Quoted boolean check should only check values [\#415](https://github.com/rodjek/puppet-lint/issues/415)
- tabs before code issue [\#402](https://github.com/rodjek/puppet-lint/issues/402)
- Disabled checks aren't actually disabled, output is merely ignored. [\#400](https://github.com/rodjek/puppet-lint/issues/400)
- file modes doesn't have to be 4 digit octal [\#394](https://github.com/rodjek/puppet-lint/issues/394)
- Option to disable top-scope variable warning for $facts and $trusted hashes [\#382](https://github.com/rodjek/puppet-lint/issues/382)
- top-scope variable check incorrectly warning on second parameter in block [\#380](https://github.com/rodjek/puppet-lint/issues/380)
- Looking for a tool that shows the output of puppet-lint and rspec-puppet on a screen like jenkins [\#374](https://github.com/rodjek/puppet-lint/issues/374)
- Puppet lint should warn on semi colon usage when used without compression [\#367](https://github.com/rodjek/puppet-lint/issues/367)
- "indentation of =\> is not properly aligned" and "ensure found on line but it's not the first attribute" weirdness [\#365](https://github.com/rodjek/puppet-lint/issues/365)
- Run via jenkins complains about autoload module layout [\#361](https://github.com/rodjek/puppet-lint/issues/361)
- Installing gems / puppet-lint may break puppet-enterprise [\#358](https://github.com/rodjek/puppet-lint/issues/358)
- Double arrow after "symlink target specified in ensure attr" fix [\#341](https://github.com/rodjek/puppet-lint/issues/341)
- "puppet:// URL without modules/" - in the style guide?  Custom mount points? [\#307](https://github.com/rodjek/puppet-lint/issues/307)
- Autoloader layout test fails inside a \(custom named\) module directory [\#265](https://github.com/rodjek/puppet-lint/issues/265)
- Check for trailing comma in last line of a attribute/value list [\#237](https://github.com/rodjek/puppet-lint/issues/237)
- Catch code outside of class or define block. [\#220](https://github.com/rodjek/puppet-lint/issues/220)
- Catch global code outside of node blocks [\#160](https://github.com/rodjek/puppet-lint/issues/160)
- Add a warning for resources outside of a class [\#69](https://github.com/rodjek/puppet-lint/issues/69)
- Release a new build, 2.0.1 [\#519](https://github.com/rodjek/puppet-lint/issues/519)
- Puppet-Lint 1.1.0 unhandled issue causing exit during -f [\#366](https://github.com/rodjek/puppet-lint/issues/366)

**Merged pull requests:**

- \(GH462\) Multi-line comments can now be fixed. [\#525](https://github.com/rodjek/puppet-lint/pull/525) ([rnelson0](https://github.com/rnelson0))
- New additions of protected variables [\#524](https://github.com/rodjek/puppet-lint/pull/524) ([rnelson0](https://github.com/rnelson0))
- \(GH366\) Arrow Alignment fix crashes with tabs [\#515](https://github.com/rodjek/puppet-lint/pull/515) ([rnelson0](https://github.com/rnelson0))
- Make params disabled [\#511](https://github.com/rodjek/puppet-lint/pull/511) ([binford2k](https://github.com/binford2k))
- Removing params class check  [\#510](https://github.com/rodjek/puppet-lint/pull/510) ([cvquesty](https://github.com/cvquesty))
- Tweak travis a bit for better patterns. [\#505](https://github.com/rodjek/puppet-lint/pull/505) ([rnelson0](https://github.com/rnelson0))
- Bugfix: properly handling $gronk-$grouik with --fix \(fix \#442\) [\#500](https://github.com/rodjek/puppet-lint/pull/500) ([Lucas-C](https://github.com/Lucas-C))
- Improve look of rspec [\#496](https://github.com/rodjek/puppet-lint/pull/496) ([rnelson0](https://github.com/rnelson0))
- This adds a disabled-by-default 80chars check [\#495](https://github.com/rodjek/puppet-lint/pull/495) ([binford2k](https://github.com/binford2k))
- Add better description of the problem in arrow\_alignment check [\#492](https://github.com/rodjek/puppet-lint/pull/492) ([rnelson0](https://github.com/rnelson0))
- \(GH410\) Limit ensure\_first\_param check to certain resources [\#490](https://github.com/rodjek/puppet-lint/pull/490) ([rnelson0](https://github.com/rnelson0))
- Regression from 418: duplicate constant [\#483](https://github.com/rodjek/puppet-lint/pull/483) ([rnelson0](https://github.com/rnelson0))
- Add fully-detailed CHANGELOG [\#481](https://github.com/rodjek/puppet-lint/pull/481) ([petems](https://github.com/petems))
- Add a CHANGELOG [\#480](https://github.com/rodjek/puppet-lint/pull/480) ([rnelson0](https://github.com/rnelson0))
- Add file mode checks for concat module [\#473](https://github.com/rodjek/puppet-lint/pull/473) ([danieljamesscott](https://github.com/danieljamesscott))
- Fix handling of empty code [\#469](https://github.com/rodjek/puppet-lint/pull/469) ([hanazuki](https://github.com/hanazuki))
- Allow regex params for puppet data types [\#468](https://github.com/rodjek/puppet-lint/pull/468) ([thejandroman](https://github.com/thejandroman))
- Support automatic fixing in Rake task as described in README [\#465](https://github.com/rodjek/puppet-lint/pull/465) ([hanazuki](https://github.com/hanazuki))
- Fix double arrow issue when adding target to ensure symlink [\#454](https://github.com/rodjek/puppet-lint/pull/454) ([mterzo](https://github.com/mterzo))
- Add future parser's Puppet Types token type [\#435](https://github.com/rodjek/puppet-lint/pull/435) ([mcanevet](https://github.com/mcanevet))
- Parameters ordering was only checked on defined types [\#429](https://github.com/rodjek/puppet-lint/pull/429) ([ctoa](https://github.com/ctoa))
- Check that variables are lowercase [\#418](https://github.com/rodjek/puppet-lint/pull/418) ([rothsa](https://github.com/rothsa))

## [2.0.0](https://github.com/rodjek/puppet-lint/tree/2.0.0) (2016-06-22)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/1.1.0...2.0.0)

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
- Only clear task if it's already defined [\#376](https://github.com/rodjek/puppet-lint/pull/376) ([domcleal](https://github.com/domcleal))
- Nested cases [\#368](https://github.com/rodjek/puppet-lint/pull/368) ([jonnangle](https://github.com/jonnangle))
- rpearce: Allow the use of facts\[\] and trusted\[\] as per Puppet 3.5+ [\#362](https://github.com/rodjek/puppet-lint/pull/362) ([rjpearce](https://github.com/rjpearce))
- Add node\_indexes method [\#351](https://github.com/rodjek/puppet-lint/pull/351) ([mcanevet](https://github.com/mcanevet))
- Don't attempt to fix ignored problems [\#349](https://github.com/rodjek/puppet-lint/pull/349) ([rodjek](https://github.com/rodjek))
- Handle case where a colon is the last token in a file [\#346](https://github.com/rodjek/puppet-lint/pull/346) ([rodjek](https://github.com/rodjek))
- Fix bug in unquoted\_node\_name to support multiple node blocks [\#345](https://github.com/rodjek/puppet-lint/pull/345) ([rodjek](https://github.com/rodjek))
- Catch Errno::EACCES when reading a puppet-lint.rc out of HOME [\#342](https://github.com/rodjek/puppet-lint/pull/342) ([rodjek](https://github.com/rodjek))
- Add support for '--relative' option in new Rake::Task format. [\#334](https://github.com/rodjek/puppet-lint/pull/334) ([fatmcgav](https://github.com/fatmcgav))
- fix \#331 - clear any pre-\(auto-\)existing tasks [\#332](https://github.com/rodjek/puppet-lint/pull/332) ([duritong](https://github.com/duritong))
- Don't warn for arrow alignment for single-element hashes [\#330](https://github.com/rodjek/puppet-lint/pull/330) ([domcleal](https://github.com/domcleal))
- Alternative to \#289: :error on either class names and defines [\#290](https://github.com/rodjek/puppet-lint/pull/290) ([ppp0](https://github.com/ppp0))

## [1.1.0](https://github.com/rodjek/puppet-lint/tree/1.1.0) (2014-09-23)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/1.0.1...1.1.0)

**Closed issues:**

- Allow overriding filename for autoloader\_layout [\#316](https://github.com/rodjek/puppet-lint/issues/316)
- Alignment warning when =\> are all aligned.  [\#309](https://github.com/rodjek/puppet-lint/issues/309)
- Run with future parser? [\#306](https://github.com/rodjek/puppet-lint/issues/306)
- Pull in variables defined from inherited classes for top\_scope\_variables check [\#304](https://github.com/rodjek/puppet-lint/issues/304)
- puppet-lint unqouted\_node\_name only checks \(and fixes\) first entry [\#323](https://github.com/rodjek/puppet-lint/issues/323)
- Class param\_tokens on unparameterised class returns function arguments [\#319](https://github.com/rodjek/puppet-lint/issues/319)
- Performance on largeish files for 1.0.0 and 1.0.1 is much slower [\#315](https://github.com/rodjek/puppet-lint/issues/315)
- Multiple ignores on one line [\#314](https://github.com/rodjek/puppet-lint/issues/314)
- --fix doesn't handle multiple "=\>" on the same line properly [\#312](https://github.com/rodjek/puppet-lint/issues/312)
- --fix converts "param=\>" to "=\>" [\#311](https://github.com/rodjek/puppet-lint/issues/311)
- Make top scope variable check respect metaparameters for defined types [\#310](https://github.com/rodjek/puppet-lint/issues/310)
- Installation instructions on front page should include how to install it with puppet [\#308](https://github.com/rodjek/puppet-lint/issues/308)
- Make rake task accept optional list of files to check [\#305](https://github.com/rodjek/puppet-lint/issues/305)

**Merged pull requests:**

- Extend the rake task to support setting configuration options in the block [\#326](https://github.com/rodjek/puppet-lint/pull/326) ([rodjek](https://github.com/rodjek))
- Support multiple commands in a single control comment [\#325](https://github.com/rodjek/puppet-lint/pull/325) ([rodjek](https://github.com/rodjek))
- Support for multiple node names in unquoted\_node\_name [\#324](https://github.com/rodjek/puppet-lint/pull/324) ([rodjek](https://github.com/rodjek))
- Handle multiple parameters on a line when fixing arrow\_alignment problems [\#322](https://github.com/rodjek/puppet-lint/pull/322) ([rodjek](https://github.com/rodjek))
- Support of metaparameter variables in variable\_scope check [\#321](https://github.com/rodjek/puppet-lint/pull/321) ([rodjek](https://github.com/rodjek))
- Don't parse class body when searching for parameter tokens [\#320](https://github.com/rodjek/puppet-lint/pull/320) ([domcleal](https://github.com/domcleal))
- Insert :WHITESPACE token between :NAME and :FARROW if needed [\#318](https://github.com/rodjek/puppet-lint/pull/318) ([rodjek](https://github.com/rodjek))
- Cache parsing state in Lexer rather than recalculating [\#317](https://github.com/rodjek/puppet-lint/pull/317) ([rodjek](https://github.com/rodjek))

## [1.0.1](https://github.com/rodjek/puppet-lint/tree/1.0.1) (2014-08-20)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/1.0.0...1.0.1)

**Closed issues:**

- Cut a new release. [\#259](https://github.com/rodjek/puppet-lint/issues/259)
- Exception with PE 3.0 [\#231](https://github.com/rodjek/puppet-lint/issues/231)
- Puppet-lint should warn on files that do not end with a trailing newline [\#188](https://github.com/rodjek/puppet-lint/issues/188)
- Breaks if ressource collector is present [\#301](https://github.com/rodjek/puppet-lint/issues/301)
- puppet-lint issues scope warnings for array/hash access [\#291](https://github.com/rodjek/puppet-lint/issues/291)

**Merged pull requests:**

- Handle empty blocks in arrow\_alignment [\#302](https://github.com/rodjek/puppet-lint/pull/302) ([rodjek](https://github.com/rodjek))
- \[Fixes \#291\] Ignore index braces for scope variables [\#303](https://github.com/rodjek/puppet-lint/pull/303) ([dcarley](https://github.com/dcarley))

## [1.0.0](https://github.com/rodjek/puppet-lint/tree/1.0.0) (2014-08-18)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.4.0.pre1...1.0.0)

**Implemented enhancements:**

- Need a way to ignore a lint check for a particular line [\#247](https://github.com/rodjek/puppet-lint/issues/247)
- Trailing line comment to disable check [\#214](https://github.com/rodjek/puppet-lint/issues/214)
- disable tests on arbitrary lines or over blocks of code [\#68](https://github.com/rodjek/puppet-lint/issues/68)

**Closed issues:**

- Stop complaining about things unsupported versions of Puppet won't support. [\#281](https://github.com/rodjek/puppet-lint/issues/281)
- some ERROR checks shouldn't fire inside comments [\#272](https://github.com/rodjek/puppet-lint/issues/272)
- quoted boolean should not trigger off of a variable value in a conditional [\#268](https://github.com/rodjek/puppet-lint/issues/268)
- Fails when parsing a Puppet file with Windows line endings on Linux. [\#262](https://github.com/rodjek/puppet-lint/issues/262)
- Whitelist variables [\#260](https://github.com/rodjek/puppet-lint/issues/260)
- Syntax error not detected [\#257](https://github.com/rodjek/puppet-lint/issues/257)
- "\$ escape sequence" throws out puppet lint error [\#256](https://github.com/rodjek/puppet-lint/issues/256)
- Incorrect ensure not first attribute warning [\#254](https://github.com/rodjek/puppet-lint/issues/254)
- lint task breaks, command line works [\#253](https://github.com/rodjek/puppet-lint/issues/253)
- Boolean quotation [\#251](https://github.com/rodjek/puppet-lint/issues/251)
- Closing bracket from classes not "linting" [\#250](https://github.com/rodjek/puppet-lint/issues/250)
- Node variables being detected as a top-scope variable [\#246](https://github.com/rodjek/puppet-lint/issues/246)
- autoloader\_layout test overly dependant on the name of the current directory [\#245](https://github.com/rodjek/puppet-lint/issues/245)
- Bamboo plugin published [\#242](https://github.com/rodjek/puppet-lint/issues/242)
- puppet-lint says syntax error, puppet parser says ok [\#230](https://github.com/rodjek/puppet-lint/issues/230)
- warn when variable or parameter is not used [\#225](https://github.com/rodjek/puppet-lint/issues/225)
- Parser fails on arithmetic expressions [\#222](https://github.com/rodjek/puppet-lint/issues/222)
- Linting errors should be sent to stderr [\#218](https://github.com/rodjek/puppet-lint/issues/218)
- 2 space softabs does not always make sense when aligning array endings [\#213](https://github.com/rodjek/puppet-lint/issues/213)
- Ignore cron commands over 80 characters long [\#198](https://github.com/rodjek/puppet-lint/issues/198)
- facter fact selinux; WARNING: quoted boolean value found on line [\#197](https://github.com/rodjek/puppet-lint/issues/197)
- Recursive check [\#196](https://github.com/rodjek/puppet-lint/issues/196)
- emits ERROR when garbage outside the class definition. [\#193](https://github.com/rodjek/puppet-lint/issues/193)
- variables\_not\_enclosed sometimes fires where it shouldn't. [\#191](https://github.com/rodjek/puppet-lint/issues/191)
- Doesn't detect syntax error [\#187](https://github.com/rodjek/puppet-lint/issues/187)
- Puppet-lint doesn't fail on unbalanced curly braces [\#185](https://github.com/rodjek/puppet-lint/issues/185)
- Optionally fixing simple stuff instead of complaining [\#162](https://github.com/rodjek/puppet-lint/issues/162)
- Feature: Print the name of the file being linted [\#283](https://github.com/rodjek/puppet-lint/issues/283)
- Allow specifying a configuration file on the command line [\#267](https://github.com/rodjek/puppet-lint/issues/267)
- Future parser loop should allow for inline variable declaration without scoping [\#264](https://github.com/rodjek/puppet-lint/issues/264)
- Double Quoted Strings - should allow for strings containing single quotes [\#263](https://github.com/rodjek/puppet-lint/issues/263)
- puppet-lint should not warn "string containing only a variable" when it's used to create a hash [\#261](https://github.com/rodjek/puppet-lint/issues/261)
- ERROR: Syntax error \(try running `puppet parser validate <file>`\) on line 15 [\#258](https://github.com/rodjek/puppet-lint/issues/258)
- Variables in each incorrectly idenentified as top scope.  [\#249](https://github.com/rodjek/puppet-lint/issues/249)
- puppet-lint -f makes a mess of double-quoted strings that contain single quotes [\#248](https://github.com/rodjek/puppet-lint/issues/248)
- Puppetlint should ignore template lines \> 80 characters [\#233](https://github.com/rodjek/puppet-lint/issues/233)
- Syntax error when parser future features used [\#232](https://github.com/rodjek/puppet-lint/issues/232)
- Issue with puppet-lint -f and trailing whitespace [\#224](https://github.com/rodjek/puppet-lint/issues/224)
- escape a variable interpolation to skip checking [\#219](https://github.com/rodjek/puppet-lint/issues/219)
- wrong  title for \>80char per line check site [\#209](https://github.com/rodjek/puppet-lint/issues/209)
- `rake lint` should respect .puppet-lint.rc in root of module [\#202](https://github.com/rodjek/puppet-lint/issues/202)
- lint analyzes inlined ruby code [\#201](https://github.com/rodjek/puppet-lint/issues/201)
- --with-context causes error [\#200](https://github.com/rodjek/puppet-lint/issues/200)
- Different results on Windows and Mac [\#195](https://github.com/rodjek/puppet-lint/issues/195)
- Fixing of double quoted strings doesn't escape single quote inside [\#182](https://github.com/rodjek/puppet-lint/issues/182)
- Fixing of string with array addressing wrong [\#181](https://github.com/rodjek/puppet-lint/issues/181)
- Puppet lint seems to ignore --no-class\_parameter\_defaults-check when inheriting the params class [\#173](https://github.com/rodjek/puppet-lint/issues/173)
- Quoting top level variable in class parameter cause false warning [\#170](https://github.com/rodjek/puppet-lint/issues/170)
- exec and Bash vars, false-postive "single quoted string containing a variable found on line" [\#113](https://github.com/rodjek/puppet-lint/issues/113)

**Merged pull requests:**

- explains in README that puppet-lint is not for checking syntax [\#186](https://github.com/rodjek/puppet-lint/pull/186) ([ghoneycutt](https://github.com/ghoneycutt))
- Use the current workdir as reference to calculate the expanded\_path of a filename [\#175](https://github.com/rodjek/puppet-lint/pull/175) ([vStone](https://github.com/vStone))
- Update code documentation [\#298](https://github.com/rodjek/puppet-lint/pull/298) ([rodjek](https://github.com/rodjek))
- Add option to load config from specified file [\#297](https://github.com/rodjek/puppet-lint/pull/297) ([rodjek](https://github.com/rodjek))
- Ensure check methods can't modify tokens array [\#296](https://github.com/rodjek/puppet-lint/pull/296) ([rodjek](https://github.com/rodjek))
- Allow single quoted strings in double quoted strings [\#295](https://github.com/rodjek/puppet-lint/pull/295) ([rodjek](https://github.com/rodjek))
- Move dependency info into gemspec [\#294](https://github.com/rodjek/puppet-lint/pull/294) ([rodjek](https://github.com/rodjek))
- Support future parser loop local scope variables [\#293](https://github.com/rodjek/puppet-lint/pull/293) ([rodjek](https://github.com/rodjek))
- Fix problems after all checks have finished [\#292](https://github.com/rodjek/puppet-lint/pull/292) ([rodjek](https://github.com/rodjek))
- Enable --with-filename by default if checking multiple files [\#287](https://github.com/rodjek/puppet-lint/pull/287) ([rodjek](https://github.com/rodjek))
- Automatically convert multiline comments into many single line comments [\#286](https://github.com/rodjek/puppet-lint/pull/286) ([rodjek](https://github.com/rodjek))
- Move to rspec3 [\#285](https://github.com/rodjek/puppet-lint/pull/285) ([rodjek](https://github.com/rodjek))
- Automatically fix ensure\_not\_symlink\_target problems [\#284](https://github.com/rodjek/puppet-lint/pull/284) ([rodjek](https://github.com/rodjek))
- Allow strings containing only a variable if they're used as hash keys [\#280](https://github.com/rodjek/puppet-lint/pull/280) ([rodjek](https://github.com/rodjek))
- Compressed arrow\_alignment [\#279](https://github.com/rodjek/puppet-lint/pull/279) ([rodjek](https://github.com/rodjek))
- Array ref variables [\#278](https://github.com/rodjek/puppet-lint/pull/278) ([rodjek](https://github.com/rodjek))
- Add docs badge to README [\#277](https://github.com/rodjek/puppet-lint/pull/277) ([rrrene](https://github.com/rrrene))
- Make array refs part of the variable name [\#276](https://github.com/rodjek/puppet-lint/pull/276) ([rodjek](https://github.com/rodjek))
- Don't automatically pad comment content with whitespace [\#275](https://github.com/rodjek/puppet-lint/pull/275) ([rodjek](https://github.com/rodjek))
- Use \#write instead of \#puts when writing fixed manifest [\#274](https://github.com/rodjek/puppet-lint/pull/274) ([rodjek](https://github.com/rodjek))
- Add --fix back to optionparser [\#273](https://github.com/rodjek/puppet-lint/pull/273) ([rodjek](https://github.com/rodjek))
- Initial spike of control comment logic [\#266](https://github.com/rodjek/puppet-lint/pull/266) ([rodjek](https://github.com/rodjek))
- Abort rake on lint error [\#255](https://github.com/rodjek/puppet-lint/pull/255) ([rodjek](https://github.com/rodjek))
- Add --relative command line argument for autoload structure testing [\#252](https://github.com/rodjek/puppet-lint/pull/252) ([ryanuber](https://github.com/ryanuber))
- DRY up the checks [\#244](https://github.com/rodjek/puppet-lint/pull/244) ([rodjek](https://github.com/rodjek))
- Refactor out linenumber in problems [\#243](https://github.com/rodjek/puppet-lint/pull/243) ([rodjek](https://github.com/rodjek))
- Ignore 80chars on lines that have long template\(\) paths [\#241](https://github.com/rodjek/puppet-lint/pull/241) ([rodjek](https://github.com/rodjek))
- Have the rake task read options from .puppet-lint.rc [\#240](https://github.com/rodjek/puppet-lint/pull/240) ([rodjek](https://github.com/rodjek))
- Support pipe char \(used in the "future" parser\) [\#239](https://github.com/rodjek/puppet-lint/pull/239) ([rodjek](https://github.com/rodjek))
- Rejig tests [\#238](https://github.com/rodjek/puppet-lint/pull/238) ([rodjek](https://github.com/rodjek))
- Allow double quotes for puppet supported escape sequences [\#234](https://github.com/rodjek/puppet-lint/pull/234) ([xarses](https://github.com/xarses))
- Allow specifying a list of checks that should run [\#228](https://github.com/rodjek/puppet-lint/pull/228) ([rodjek](https://github.com/rodjek))
- Split checking and reporting logic [\#227](https://github.com/rodjek/puppet-lint/pull/227) ([rodjek](https://github.com/rodjek))
- Refactor check plugins to have slightly less awful magic [\#226](https://github.com/rodjek/puppet-lint/pull/226) ([rodjek](https://github.com/rodjek))
- Add %{column} to help text of --log-format [\#221](https://github.com/rodjek/puppet-lint/pull/221) ([bdd](https://github.com/bdd))
- Bad hash indenting with --fix where members declared on a single line [\#217](https://github.com/rodjek/puppet-lint/pull/217) ([aelse](https://github.com/aelse))
- Handle variables with array & hash references [\#212](https://github.com/rodjek/puppet-lint/pull/212) ([rodjek](https://github.com/rodjek))
- Add Modulo token [\#207](https://github.com/rodjek/puppet-lint/pull/207) ([dalen](https://github.com/dalen))
- incorrect top-scope variable warning for define [\#205](https://github.com/rodjek/puppet-lint/pull/205) ([blalor](https://github.com/blalor))
- --fix doesn't modify my file [\#203](https://github.com/rodjek/puppet-lint/pull/203) ([BillWeiss](https://github.com/BillWeiss))
- Don't warn about 'mode' format when it's an 'audit' value [\#199](https://github.com/rodjek/puppet-lint/pull/199) ([bitfield](https://github.com/bitfield))
- Doesn't recognize paramater containing default value if value is double quoted. [\#194](https://github.com/rodjek/puppet-lint/pull/194) ([jcray](https://github.com/jcray))
- Running with --fix deletes all code for files containing invalid syntax [\#184](https://github.com/rodjek/puppet-lint/pull/184) ([devicenull](https://github.com/devicenull))
- Puppet-lint fails to handle mac line endings [\#183](https://github.com/rodjek/puppet-lint/pull/183) ([devicenull](https://github.com/devicenull))
- Lone dollar sign should not be removed [\#180](https://github.com/rodjek/puppet-lint/pull/180) ([Seldaek](https://github.com/Seldaek))
- Warn about unquoted node names [\#177](https://github.com/rodjek/puppet-lint/pull/177) ([bitfield](https://github.com/bitfield))
- Fix the check\_classes check for certain cases. [\#176](https://github.com/rodjek/puppet-lint/pull/176) ([vStone](https://github.com/vStone))
- Invalid warning about mandatory class parameters without defaults [\#167](https://github.com/rodjek/puppet-lint/pull/167) ([svend](https://github.com/svend))
- Add check for puppet:/// URIs without modules/ [\#166](https://github.com/rodjek/puppet-lint/pull/166) ([rodjek](https://github.com/rodjek))

## [0.4.0.pre1](https://github.com/rodjek/puppet-lint/tree/0.4.0.pre1) (2013-01-28)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.3.2...0.4.0.pre1)

**Closed issues:**

- error installing puppet-lint [\#172](https://github.com/rodjek/puppet-lint/issues/172)
- puppet-lint seems to miss obvious syntax error [\#171](https://github.com/rodjek/puppet-lint/issues/171)
- ERROR with file containing DOS EOL character [\#165](https://github.com/rodjek/puppet-lint/issues/165)
- ssh key parameter will always be longer than 80 chars [\#70](https://github.com/rodjek/puppet-lint/issues/70)

**Merged pull requests:**

- Fix where . is located in docs [\#169](https://github.com/rodjek/puppet-lint/pull/169) ([gmjosack](https://github.com/gmjosack))
- Update README.md [\#168](https://github.com/rodjek/puppet-lint/pull/168) ([levpaul](https://github.com/levpaul))

## [0.3.2](https://github.com/rodjek/puppet-lint/tree/0.3.2) (2012-10-19)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.3.1...0.3.2)

**Closed issues:**

- Check "string containing only a variable" performs invalid suggestion. [\#164](https://github.com/rodjek/puppet-lint/issues/164)
- puppet-lint/lexer.rb:184:in `tokenise': ' } \(PuppetLint::LexerError\) on Ruby 1.8.7 [\#161](https://github.com/rodjek/puppet-lint/issues/161)
- Warning for 'more than 80 characters on line' is not catching all instances [\#159](https://github.com/rodjek/puppet-lint/issues/159)
- captilised variables error on puppet not with lint [\#158](https://github.com/rodjek/puppet-lint/issues/158)
- warning for 'class param without default' is not catching all instances in a file [\#157](https://github.com/rodjek/puppet-lint/issues/157)
- puppet-lint crashes if HOME environment is not set [\#156](https://github.com/rodjek/puppet-lint/issues/156)
- String monkeypatch breaks Facter under Ruby 1.8 [\#154](https://github.com/rodjek/puppet-lint/issues/154)
- Crash on string with \\ and variable [\#152](https://github.com/rodjek/puppet-lint/issues/152)

**Merged pull requests:**

- \(\#152\) Fix crash on string with \\ and variable [\#163](https://github.com/rodjek/puppet-lint/pull/163) ([dalen](https://github.com/dalen))
- fixes \#154 string monkeypatch failure [\#155](https://github.com/rodjek/puppet-lint/pull/155) ([vStone](https://github.com/vStone))

## [0.3.1](https://github.com/rodjek/puppet-lint/tree/0.3.1) (2012-09-26)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.3.0...0.3.1)

**Closed issues:**

- class\_inherits\_from\_params\_class throws exception in 0.3.0 [\#150](https://github.com/rodjek/puppet-lint/issues/150)

**Merged pull requests:**

- Fixes \#150 class inherits from params class exception [\#151](https://github.com/rodjek/puppet-lint/pull/151) ([vStone](https://github.com/vStone))

## [0.3.0](https://github.com/rodjek/puppet-lint/tree/0.3.0) (2012-09-25)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.2.1...0.3.0)

**Implemented enhancements:**

- Provide context for the problems [\#130](https://github.com/rodjek/puppet-lint/issues/130)

**Closed issues:**

- False positive unquoted resource title for colons in resource parameters [\#146](https://github.com/rodjek/puppet-lint/issues/146)
- should exit with non 0 exit code on error [\#140](https://github.com/rodjek/puppet-lint/issues/140)
- using fully qualified class names in inheritance is wrongly reported as inheritance across namespaces [\#148](https://github.com/rodjek/puppet-lint/issues/148)
- False positive on duplicate parameter checks [\#145](https://github.com/rodjek/puppet-lint/issues/145)
- Crash on \\ at end of single quoted string [\#144](https://github.com/rodjek/puppet-lint/issues/144)
- Strings ending in backslash cause exceptions [\#142](https://github.com/rodjek/puppet-lint/issues/142)
- --no-class\_parameter\_defaults-check [\#139](https://github.com/rodjek/puppet-lint/issues/139)

**Merged pull requests:**

- Fixes \#145: False positive on duplicate parameter. [\#147](https://github.com/rodjek/puppet-lint/pull/147) ([vStone](https://github.com/vStone))
- Pass exit value to the shell [\#141](https://github.com/rodjek/puppet-lint/pull/141) ([vStone](https://github.com/vStone))
- \(\#148\) Allow class inheritance within the same module [\#149](https://github.com/rodjek/puppet-lint/pull/149) ([dcarley](https://github.com/dcarley))
- use .puppet-lint.rc, as .puppet-lintrc is deprecated [\#143](https://github.com/rodjek/puppet-lint/pull/143) ([ghoneycutt](https://github.com/ghoneycutt))

## [0.2.1](https://github.com/rodjek/puppet-lint/tree/0.2.1) (2012-08-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.2.0...0.2.1)

**Closed issues:**

- Rake task breaks in 0.2.0 [\#138](https://github.com/rodjek/puppet-lint/issues/138)
- False warning : parameterised class parameter without a default value [\#137](https://github.com/rodjek/puppet-lint/issues/137)

## [0.2.0](https://github.com/rodjek/puppet-lint/tree/0.2.0) (2012-08-23)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.2.0.pre1...0.2.0)

**Implemented enhancements:**

- Variables standing by themselves should not be quoted [\#20](https://github.com/rodjek/puppet-lint/issues/20)
- write class\_parameter\_defaults check [\#134](https://github.com/rodjek/puppet-lint/issues/134)
- duplicate parameter detection [\#122](https://github.com/rodjek/puppet-lint/issues/122)

**Closed issues:**

- `require': iconv will be deprecated in the future, use String\#encode instead. [\#133](https://github.com/rodjek/puppet-lint/issues/133)
- False positive in "optional parameter listed before required parameter"? [\#126](https://github.com/rodjek/puppet-lint/issues/126)
- There's a puppet-lint 0.13.1 gem on rubygems.org but no 0.13.1 tag here [\#99](https://github.com/rodjek/puppet-lint/issues/99)
- Introduce a way to tweak warning/error level for checks [\#91](https://github.com/rodjek/puppet-lint/issues/91)
- Didn't pick up $ipaddress\_bond0 as a fact [\#61](https://github.com/rodjek/puppet-lint/issues/61)
- False positive when using function call for parameter default [\#132](https://github.com/rodjek/puppet-lint/issues/132)
- Fix up the website [\#131](https://github.com/rodjek/puppet-lint/issues/131)
- Linked list style functionality for tokens [\#129](https://github.com/rodjek/puppet-lint/issues/129)
- False positive unquoted resource title in case statements [\#128](https://github.com/rodjek/puppet-lint/issues/128)
- Crash on arrow alignment check [\#127](https://github.com/rodjek/puppet-lint/issues/127)
- Does not work on ruby 1.9.3 [\#120](https://github.com/rodjek/puppet-lint/issues/120)
- Bad class format causes exception [\#118](https://github.com/rodjek/puppet-lint/issues/118)
- case statement in inline\_template false warning [\#117](https://github.com/rodjek/puppet-lint/issues/117)
- False warning with puppet-lint-0.2 [\#116](https://github.com/rodjek/puppet-lint/issues/116)
- :lint rake tasks should not print "Evaluating" lines [\#114](https://github.com/rodjek/puppet-lint/issues/114)
- when content is specified directly, double quotes are needed to get newlines [\#109](https://github.com/rodjek/puppet-lint/issues/109)
- Incorrect variable count in string parsing [\#104](https://github.com/rodjek/puppet-lint/issues/104)
- misparses empty hash in defined resource prototype [\#101](https://github.com/rodjek/puppet-lint/issues/101)
- Allow file modes to be 'undef' [\#100](https://github.com/rodjek/puppet-lint/issues/100)
- Arrow alignment check shouldn't span over several resources [\#78](https://github.com/rodjek/puppet-lint/issues/78)
- Ignore commented lines for arrow alignment [\#77](https://github.com/rodjek/puppet-lint/issues/77)
- /etc/puppet-lint.rc please! [\#71](https://github.com/rodjek/puppet-lint/issues/71)
- checking of correct docs format [\#59](https://github.com/rodjek/puppet-lint/issues/59)
- Multiline string should not be checked for double quotes [\#51](https://github.com/rodjek/puppet-lint/issues/51)

## [0.2.0.pre1](https://github.com/rodjek/puppet-lint/tree/0.2.0.pre1) (2012-07-11)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.13...0.2.0.pre1)

**Closed issues:**

- Getting double quote warning with Augeas [\#111](https://github.com/rodjek/puppet-lint/issues/111)
- NoMethodError with Ruby 1.9.2 [\#103](https://github.com/rodjek/puppet-lint/issues/103)
- new to the lint [\#97](https://github.com/rodjek/puppet-lint/issues/97)
- inline\_templates only evaluate in double quotes, yet lint warns of no vars. [\#94](https://github.com/rodjek/puppet-lint/issues/94)
- Stop duplicate output [\#93](https://github.com/rodjek/puppet-lint/issues/93)
- add noop to variables\_in\_scope list [\#92](https://github.com/rodjek/puppet-lint/issues/92)
- Can't handle single quotes? \(slurpstring\) [\#90](https://github.com/rodjek/puppet-lint/issues/90)
- Detect missing commas [\#89](https://github.com/rodjek/puppet-lint/issues/89)
- Weird \(probably UTF-8\) problem gives false positives on 80char limit. [\#84](https://github.com/rodjek/puppet-lint/issues/84)
- Autoload module check and JenkinsCI [\#83](https://github.com/rodjek/puppet-lint/issues/83)
- "Should align arrows within blocks of attributes" check doesn't seem to work [\#75](https://github.com/rodjek/puppet-lint/issues/75)
- puppet-lintrc is ignored when running "rake lint" [\#74](https://github.com/rodjek/puppet-lint/issues/74)
- docs mention --disable-XXX, should be --no-XXX [\#73](https://github.com/rodjek/puppet-lint/issues/73)
- Added support for detecting bad string interpolation [\#40](https://github.com/rodjek/puppet-lint/issues/40)

**Merged pull requests:**

- Make rake task respect PuppetLint.configuration.fail\_on\_warnings [\#115](https://github.com/rodjek/puppet-lint/pull/115) ([wfarr](https://github.com/wfarr))
- fixes spelling and typo errors in README [\#112](https://github.com/rodjek/puppet-lint/pull/112) ([ghoneycutt](https://github.com/ghoneycutt))
- This fixes the build on Travis CI for ruby1.9 [\#110](https://github.com/rodjek/puppet-lint/pull/110) ([vStone](https://github.com/vStone))
- Fix utf8 char issues: see bug \#84 [\#108](https://github.com/rodjek/puppet-lint/pull/108) ([vStone](https://github.com/vStone))
- Add support for ignoring certain globs in the rake task [\#106](https://github.com/rodjek/puppet-lint/pull/106) ([wfarr](https://github.com/wfarr))
- Fix bug introduced in \#81 [\#98](https://github.com/rodjek/puppet-lint/pull/98) ([deizel](https://github.com/deizel))
- Fixup the variable not enclosed in {} test [\#66](https://github.com/rodjek/puppet-lint/pull/66) ([richardc](https://github.com/richardc))

## [0.1.13](https://github.com/rodjek/puppet-lint/tree/0.1.13) (2012-03-26)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.12...0.1.13)

**Closed issues:**

- Getting `warning: class variable access from toplevel` with bundler [\#85](https://github.com/rodjek/puppet-lint/issues/85)
- Suppress "string containing only a variable" warnings on defines? [\#79](https://github.com/rodjek/puppet-lint/issues/79)
- puppet-lint equivalent to rakefile's require 'puppet-lint/tasks/puppet-lint' [\#72](https://github.com/rodjek/puppet-lint/issues/72)
- Support symbolic file modes for \>= 2.7.10 [\#60](https://github.com/rodjek/puppet-lint/issues/60)

**Merged pull requests:**

- Update readme to reflect the current names of the flags for disabling checks [\#88](https://github.com/rodjek/puppet-lint/pull/88) ([garethr](https://github.com/garethr))
- Add additional puppet variables. [\#82](https://github.com/rodjek/puppet-lint/pull/82) ([nanliu](https://github.com/nanliu))
- Add support run puppet-lint on directory. [\#81](https://github.com/rodjek/puppet-lint/pull/81) ([nanliu](https://github.com/nanliu))
- Update travis support for multiple puppet version. [\#80](https://github.com/rodjek/puppet-lint/pull/80) ([nanliu](https://github.com/nanliu))
- Find booleans in double quoted strings [\#67](https://github.com/rodjek/puppet-lint/pull/67) ([richardc](https://github.com/richardc))
- Feature/symbolic filemodes \(cfr ticket \#60\) [\#62](https://github.com/rodjek/puppet-lint/pull/62) ([vStone](https://github.com/vStone))

## [0.1.12](https://github.com/rodjek/puppet-lint/tree/0.1.12) (2012-01-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.11...0.1.12)

**Closed issues:**

- ssh\_key can't be broken up by \ [\#58](https://github.com/rodjek/puppet-lint/issues/58)
- Autoload module check doesn't seem to work [\#57](https://github.com/rodjek/puppet-lint/issues/57)
- included parameterized classes check does not work [\#56](https://github.com/rodjek/puppet-lint/issues/56)
- invalid quoted string warning on resource titles [\#44](https://github.com/rodjek/puppet-lint/issues/44)
- turn off particular tests?  .puppet-lintrc? [\#34](https://github.com/rodjek/puppet-lint/issues/34)

## [0.1.11](https://github.com/rodjek/puppet-lint/tree/0.1.11) (2012-01-11)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.10...0.1.11)

## [0.1.10](https://github.com/rodjek/puppet-lint/tree/0.1.10) (2012-01-11)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.9...0.1.10)

**Closed issues:**

- Alert when more than one class/define is present in a .pp file [\#54](https://github.com/rodjek/puppet-lint/issues/54)
- Invalid top-scope variable warning in definitions. [\#50](https://github.com/rodjek/puppet-lint/issues/50)
- Regex capture variables [\#49](https://github.com/rodjek/puppet-lint/issues/49)

**Merged pull requests:**

- Feature/unified problems [\#52](https://github.com/rodjek/puppet-lint/pull/52) ([vStone](https://github.com/vStone))

## [0.1.9](https://github.com/rodjek/puppet-lint/tree/0.1.9) (2011-12-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.8...0.1.9)

**Merged pull requests:**

- Consolidated option checking logic [\#48](https://github.com/rodjek/puppet-lint/pull/48) ([jamtur01](https://github.com/jamtur01))

## [0.1.8](https://github.com/rodjek/puppet-lint/tree/0.1.8) (2011-12-27)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.7...0.1.8)

**Closed issues:**

- Add option to control which error level is returned [\#45](https://github.com/rodjek/puppet-lint/issues/45)
- "false" != false \(ditto for true\) [\#43](https://github.com/rodjek/puppet-lint/issues/43)
- Facter variables are seen as unnamespaced top-level variables [\#42](https://github.com/rodjek/puppet-lint/issues/42)
- WARNING: =\> on line 13 isn't aligned with the previous line [\#37](https://github.com/rodjek/puppet-lint/issues/37)
- single quotes in a manifest causes an exception [\#36](https://github.com/rodjek/puppet-lint/issues/36)
- Invalid "optional parameter listed before required parameter" warning. [\#35](https://github.com/rodjek/puppet-lint/issues/35)
- Resource types containing only a variable [\#30](https://github.com/rodjek/puppet-lint/issues/30)

**Merged pull requests:**

- \[\#9\] add stack to allow nested hashes [\#47](https://github.com/rodjek/puppet-lint/pull/47) ([zsprackett](https://github.com/zsprackett))
- Fixed \#45 - Added selective error level reporting [\#46](https://github.com/rodjek/puppet-lint/pull/46) ([jamtur01](https://github.com/jamtur01))
- Added check for dashes in variables [\#41](https://github.com/rodjek/puppet-lint/pull/41) ([jamtur01](https://github.com/jamtur01))
- Add filename as first test\(\) argument so plugins can use that too [\#39](https://github.com/rodjek/puppet-lint/pull/39) ([vStone](https://github.com/vStone))

## [0.1.7](https://github.com/rodjek/puppet-lint/tree/0.1.7) (2011-10-18)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.4...0.1.7)

**Closed issues:**

- missing dependency on "puppet" gem [\#33](https://github.com/rodjek/puppet-lint/issues/33)
- "class defined inside a class" even when class is a resource \(parameterized Class\) [\#32](https://github.com/rodjek/puppet-lint/issues/32)
- Classes inside classes should be allowed when order matters [\#31](https://github.com/rodjek/puppet-lint/issues/31)
- doesn't work...at all [\#29](https://github.com/rodjek/puppet-lint/issues/29)
- "mode should be represented as a 4 digit octal value" when variable [\#28](https://github.com/rodjek/puppet-lint/issues/28)

## [0.1.4](https://github.com/rodjek/puppet-lint/tree/0.1.4) (2011-09-09)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.3...0.1.4)

**Closed issues:**

- String containing escape char \(and no var\) incorrectly flagged [\#26](https://github.com/rodjek/puppet-lint/issues/26)
- False alignment positives [\#21](https://github.com/rodjek/puppet-lint/issues/21)

## [0.1.3](https://github.com/rodjek/puppet-lint/tree/0.1.3) (2011-09-09)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.2...0.1.3)

## [0.1.2](https://github.com/rodjek/puppet-lint/tree/0.1.2) (2011-09-09)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.1...0.1.2)

**Closed issues:**

- double quote within single quote [\#24](https://github.com/rodjek/puppet-lint/issues/24)
- False positive in commented line [\#22](https://github.com/rodjek/puppet-lint/issues/22)

## [0.1.1](https://github.com/rodjek/puppet-lint/tree/0.1.1) (2011-09-07)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.1.0...0.1.1)

**Closed issues:**

- $name is detected as a top-scope variable [\#23](https://github.com/rodjek/puppet-lint/issues/23)
- Not detecting comma and semicolon being mixed up [\#13](https://github.com/rodjek/puppet-lint/issues/13)

## [0.1.0](https://github.com/rodjek/puppet-lint/tree/0.1.0) (2011-08-23)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.7...0.1.0)

**Implemented enhancements:**

- display order of class/define parameters [\#19](https://github.com/rodjek/puppet-lint/issues/19)
- class inheritance [\#18](https://github.com/rodjek/puppet-lint/issues/18)
- classes and defined types within classes [\#17](https://github.com/rodjek/puppet-lint/issues/17)
- relationship declarations [\#16](https://github.com/rodjek/puppet-lint/issues/16)
- defaults for case statements and selectors [\#15](https://github.com/rodjek/puppet-lint/issues/15)
- namespacing variables [\#14](https://github.com/rodjek/puppet-lint/issues/14)

**Closed issues:**

- =\> alignment warnings in selectors is broken [\#11](https://github.com/rodjek/puppet-lint/issues/11)

## [0.0.7](https://github.com/rodjek/puppet-lint/tree/0.0.7) (2011-08-21)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.6...0.0.7)

## [0.0.6](https://github.com/rodjek/puppet-lint/tree/0.0.6) (2011-08-19)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.5...0.0.6)

**Implemented enhancements:**

- Please add logic to the \>80 chars check [\#12](https://github.com/rodjek/puppet-lint/issues/12)

## [0.0.5](https://github.com/rodjek/puppet-lint/tree/0.0.5) (2011-08-19)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.4...0.0.5)

**Closed issues:**

- When ensure is the only attribute it is the first one too. [\#10](https://github.com/rodjek/puppet-lint/issues/10)
- Shell commands with curly brackets \(e.g. awk\) [\#9](https://github.com/rodjek/puppet-lint/issues/9)
- "single quoted string containing a variable" should check for nested quotes [\#7](https://github.com/rodjek/puppet-lint/issues/7)

## [0.0.4](https://github.com/rodjek/puppet-lint/tree/0.0.4) (2011-08-18)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.3...0.0.4)

**Closed issues:**

- "ensure is not the first attribute" does not check for aggregated resources [\#8](https://github.com/rodjek/puppet-lint/issues/8)
- Square brackets trigger "WARNING: unquoted resource title" [\#5](https://github.com/rodjek/puppet-lint/issues/5)
- Nasty stacktrace when trying to run lint against a non existance file [\#4](https://github.com/rodjek/puppet-lint/issues/4)

## [0.0.3](https://github.com/rodjek/puppet-lint/tree/0.0.3) (2011-08-17)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.2...0.0.3)

**Closed issues:**

- Invalid "ensure is not the first attribute" [\#3](https://github.com/rodjek/puppet-lint/issues/3)
- Empty variables break check\_strings plugin [\#2](https://github.com/rodjek/puppet-lint/issues/2)

## [0.0.2](https://github.com/rodjek/puppet-lint/tree/0.0.2) (2011-08-17)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/0.0.1...0.0.2)

**Merged pull requests:**

- Here, have some Rake support [\#1](https://github.com/rodjek/puppet-lint/pull/1) ([builddoctor](https://github.com/builddoctor))

## [0.0.1](https://github.com/rodjek/puppet-lint/tree/0.0.1) (2011-08-15)

[Full Changelog](https://github.com/rodjek/puppet-lint/compare/2dd42b803a4dfc3a2398a509d26f285c9427ba41...0.0.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
