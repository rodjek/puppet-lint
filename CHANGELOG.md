<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v4.1.0](https://github.com/puppetlabs/puppet-lint/tree/v4.1.0) - 2023-08-25

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v4.0.1...v4.1.0)

### Added

- (CAT-1301) Add check unsafe interpolations check [#142](https://github.com/puppetlabs/puppet-lint/pull/142) ([GSPatton](https://github.com/GSPatton))

## [v4.0.1](https://github.com/puppetlabs/puppet-lint/tree/v4.0.1) - 2023-07-31

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v4.0.0...v4.0.1)

### Fixed

- (CAT-1167) Fix failing legacy fact autocorrector [#138](https://github.com/puppetlabs/puppet-lint/pull/138) ([LukasAud](https://github.com/LukasAud))
- (GH-122) Fix bad detection of optional parameters out of order [#123](https://github.com/puppetlabs/puppet-lint/pull/123) ([tiandrey](https://github.com/tiandrey))
- Do not crash when referring to a fact key without quoting it [#119](https://github.com/puppetlabs/puppet-lint/pull/119) ([chutzimir](https://github.com/chutzimir))

## [v4.0.0](https://github.com/puppetlabs/puppet-lint/tree/v4.0.0) - 2023-04-21

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v3.4.0...v4.0.0)

### Changed
- (CONT-811) Add Ruby 3.2 support and Remove support for Ruby 2.5 [#113](https://github.com/puppetlabs/puppet-lint/pull/113) ([GSPatton](https://github.com/GSPatton))

## [v3.4.0](https://github.com/puppetlabs/puppet-lint/tree/v3.4.0) - 2023-04-05

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v3.3.0...v3.4.0)

### Fixed

- (maint) Update issues URL [#112](https://github.com/puppetlabs/puppet-lint/pull/112) ([pmcmaw](https://github.com/pmcmaw))

## [v3.3.0](https://github.com/puppetlabs/puppet-lint/tree/v3.3.0) - 2023-03-07

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v3.2.0...v3.3.0)

### Fixed

- (maint) Corrects legacy macOS facts [#103](https://github.com/puppetlabs/puppet-lint/pull/103) ([mhashizume](https://github.com/mhashizume))

## [v3.2.0](https://github.com/puppetlabs/puppet-lint/tree/v3.2.0) - 2023-02-28

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v3.1.0...v3.2.0)

### Added

- codeclimate (GitLab Code Quality compatible) output support  [#79](https://github.com/puppetlabs/puppet-lint/pull/79) ([alexjfisher](https://github.com/alexjfisher))

### Fixed

- (CONT-675) Fix fact detection [#96](https://github.com/puppetlabs/puppet-lint/pull/96) ([chelnak](https://github.com/chelnak))

## [v3.1.0](https://github.com/puppetlabs/puppet-lint/tree/v3.1.0) - 2023-02-28

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v3.0.1...v3.1.0)

### Added

- (CONT-670) Add legacy facts check [#91](https://github.com/puppetlabs/puppet-lint/pull/91) ([chelnak](https://github.com/chelnak))
- (CONT-339) Lower Ruby requirement [#87](https://github.com/puppetlabs/puppet-lint/pull/87) ([chelnak](https://github.com/chelnak))
- (CONT-339) Add top scope facts check [#85](https://github.com/puppetlabs/puppet-lint/pull/85) ([chelnak](https://github.com/chelnak))

### Fixed

- (CONT-666) Skip classref types [#93](https://github.com/puppetlabs/puppet-lint/pull/93) ([chelnak](https://github.com/chelnak))
- Fix first token whitespace [#86](https://github.com/puppetlabs/puppet-lint/pull/86) ([nwoythal](https://github.com/nwoythal))
- Fix assertion when rspec-json_expectations is missing [#75](https://github.com/puppetlabs/puppet-lint/pull/75) ([ekohl](https://github.com/ekohl))
- (CONT-214) Fix rubocop inheritance [#70](https://github.com/puppetlabs/puppet-lint/pull/70) ([chelnak](https://github.com/chelnak))

## [v3.0.1](https://github.com/puppetlabs/puppet-lint/tree/v3.0.1) - 2022-10-20

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/v3.0.0...v3.0.1)

### Fixed

- Fix plugin regressions introduced in 3.0.0 [#66](https://github.com/puppetlabs/puppet-lint/pull/66) ([ekohl](https://github.com/ekohl))

## [v3.0.0](https://github.com/puppetlabs/puppet-lint/tree/v3.0.0) - 2022-10-13

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.5.2...v3.0.0)

### Added

- (GH-47) Expose additional indexes [#48](https://github.com/puppetlabs/puppet-lint/pull/48) ([chelnak](https://github.com/chelnak))
- Add SARIF support [#40](https://github.com/puppetlabs/puppet-lint/pull/40) ([shaopeng-gh](https://github.com/shaopeng-gh))
- Add GitHub Actions annotations [#34](https://github.com/puppetlabs/puppet-lint/pull/34) ([ekohl](https://github.com/ekohl))

### Changed
- (MAINT) bump ruby version [#50](https://github.com/puppetlabs/puppet-lint/pull/50) ([chelnak](https://github.com/chelnak))

### Fixed

- Don't print GitHub annotations in JSON mode [#35](https://github.com/puppetlabs/puppet-lint/pull/35) ([ekohl](https://github.com/ekohl))

## [2.5.2](https://github.com/puppetlabs/puppet-lint/tree/2.5.2) - 2021-09-14

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.5.1...2.5.2)

## [2.5.1](https://github.com/puppetlabs/puppet-lint/tree/2.5.1) - 2021-09-13

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.5.0...2.5.1)

### Fixed

- (GH-16) Do not warn on "\s" string literal [#20](https://github.com/puppetlabs/puppet-lint/pull/20) ([sanfrancrisko](https://github.com/sanfrancrisko))

## [2.5.0](https://github.com/puppetlabs/puppet-lint/tree/2.5.0) - 2021-07-26

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.4.2...2.5.0)

## [2.4.2](https://github.com/puppetlabs/puppet-lint/tree/2.4.2) - 2019-10-31

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.4.1...2.4.2)

## [2.4.1](https://github.com/puppetlabs/puppet-lint/tree/2.4.1) - 2019-10-09

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.4.0...2.4.1)

## [2.4.0](https://github.com/puppetlabs/puppet-lint/tree/2.4.0) - 2019-10-08

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.6...2.4.0)

## [2.3.6](https://github.com/puppetlabs/puppet-lint/tree/2.3.6) - 2018-07-09

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.5...2.3.6)

## [2.3.5](https://github.com/puppetlabs/puppet-lint/tree/2.3.5) - 2018-03-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.4...2.3.5)

## [2.3.4](https://github.com/puppetlabs/puppet-lint/tree/2.3.4) - 2018-03-26

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.3...2.3.4)

## [2.3.3](https://github.com/puppetlabs/puppet-lint/tree/2.3.3) - 2017-09-28

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.2...2.3.3)

## [2.3.2](https://github.com/puppetlabs/puppet-lint/tree/2.3.2) - 2017-09-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.1...2.3.2)

## [2.3.1](https://github.com/puppetlabs/puppet-lint/tree/2.3.1) - 2017-09-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.3.0...2.3.1)

## [2.3.0](https://github.com/puppetlabs/puppet-lint/tree/2.3.0) - 2017-07-12

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.2.1...2.3.0)

## [2.2.1](https://github.com/puppetlabs/puppet-lint/tree/2.2.1) - 2017-03-29

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.2.0...2.2.1)

## [2.2.0](https://github.com/puppetlabs/puppet-lint/tree/2.2.0) - 2017-03-29

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.1.1...2.2.0)

## [2.1.1](https://github.com/puppetlabs/puppet-lint/tree/2.1.1) - 2017-02-14

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.1.0...2.1.1)

## [2.1.0](https://github.com/puppetlabs/puppet-lint/tree/2.1.0) - 2016-12-30

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.0.2...2.1.0)

## [2.0.2](https://github.com/puppetlabs/puppet-lint/tree/2.0.2) - 2016-08-18

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.0.1...2.0.2)

## [2.0.1](https://github.com/puppetlabs/puppet-lint/tree/2.0.1) - 2016-08-18

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2.0.0...2.0.1)

## [2.0.0](https://github.com/puppetlabs/puppet-lint/tree/2.0.0) - 2016-06-22

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/1.1.0...2.0.0)

## [1.1.0](https://github.com/puppetlabs/puppet-lint/tree/1.1.0) - 2014-09-23

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/1.0.1...1.1.0)

## [1.0.1](https://github.com/puppetlabs/puppet-lint/tree/1.0.1) - 2014-08-20

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/puppetlabs/puppet-lint/tree/1.0.0) - 2014-08-18

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.4.0.pre1...1.0.0)

## [0.4.0.pre1](https://github.com/puppetlabs/puppet-lint/tree/0.4.0.pre1) - 2013-01-28

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.3.2...0.4.0.pre1)

## [0.3.2](https://github.com/puppetlabs/puppet-lint/tree/0.3.2) - 2012-10-19

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.3.1...0.3.2)

## [0.3.1](https://github.com/puppetlabs/puppet-lint/tree/0.3.1) - 2012-09-26

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.3.0...0.3.1)

## [0.3.0](https://github.com/puppetlabs/puppet-lint/tree/0.3.0) - 2012-09-25

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.2.1...0.3.0)

## [0.2.1](https://github.com/puppetlabs/puppet-lint/tree/0.2.1) - 2012-08-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.2.0...0.2.1)

## [0.2.0](https://github.com/puppetlabs/puppet-lint/tree/0.2.0) - 2012-08-23

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.2.0.pre1...0.2.0)

## [0.2.0.pre1](https://github.com/puppetlabs/puppet-lint/tree/0.2.0.pre1) - 2012-07-11

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.13...0.2.0.pre1)

## [0.1.13](https://github.com/puppetlabs/puppet-lint/tree/0.1.13) - 2012-03-25

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.12...0.1.13)

## [0.1.12](https://github.com/puppetlabs/puppet-lint/tree/0.1.12) - 2012-01-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.11...0.1.12)

## [0.1.11](https://github.com/puppetlabs/puppet-lint/tree/0.1.11) - 2012-01-12

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.10...0.1.11)

## [0.1.10](https://github.com/puppetlabs/puppet-lint/tree/0.1.10) - 2012-01-12

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.9...0.1.10)

## [0.1.9](https://github.com/puppetlabs/puppet-lint/tree/0.1.9) - 2011-12-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.8...0.1.9)

## [0.1.8](https://github.com/puppetlabs/puppet-lint/tree/0.1.8) - 2011-12-27

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.7...0.1.8)

## [0.1.7](https://github.com/puppetlabs/puppet-lint/tree/0.1.7) - 2011-10-18

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.4...0.1.7)

## [0.1.4](https://github.com/puppetlabs/puppet-lint/tree/0.1.4) - 2011-09-10

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.3...0.1.4)

## [0.1.3](https://github.com/puppetlabs/puppet-lint/tree/0.1.3) - 2011-09-09

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.2...0.1.3)

## [0.1.2](https://github.com/puppetlabs/puppet-lint/tree/0.1.2) - 2011-09-09

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/puppetlabs/puppet-lint/tree/0.1.1) - 2011-09-07

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/puppetlabs/puppet-lint/tree/0.1.0) - 2011-08-22

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.7...0.1.0)

## [0.0.7](https://github.com/puppetlabs/puppet-lint/tree/0.0.7) - 2011-08-21

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.6...0.0.7)

## [0.0.6](https://github.com/puppetlabs/puppet-lint/tree/0.0.6) - 2011-08-19

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.5...0.0.6)

## [0.0.5](https://github.com/puppetlabs/puppet-lint/tree/0.0.5) - 2011-08-19

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.4...0.0.5)

## [0.0.4](https://github.com/puppetlabs/puppet-lint/tree/0.0.4) - 2011-08-18

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.3...0.0.4)

## [0.0.3](https://github.com/puppetlabs/puppet-lint/tree/0.0.3) - 2011-08-17

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.2...0.0.3)

## [0.0.2](https://github.com/puppetlabs/puppet-lint/tree/0.0.2) - 2011-08-16

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/0.0.1...0.0.2)

## [0.0.1](https://github.com/puppetlabs/puppet-lint/tree/0.0.1) - 2011-08-15

[Full Changelog](https://github.com/puppetlabs/puppet-lint/compare/2dd42b803a4dfc3a2398a509d26f285c9427ba41...0.0.1)
