---
layout: default
---
# Community Plugins

To use plugins, add them to your `Gemfile` or install them at the system level. You can then enable/disable checks using the `PuppetLint.configuration.send('<enable|disable>_<check_name>')` syntax in your `Rakefile`. Most checks are enabled by default.

    # Gemfile
    gem 'puppet-lint-roles_and_profiles-check'

    # Rakefile
    PuppetLint.configuration.send('disable_roles_resource_declaration')

Check the plugin's URL for more information on use of its check(s).

---

### trailing_newlines

> Checks to ensure that your manifest files end with a trailing newline.

| **URL**     | <https://github.com/rodjek/puppet-lint-trailing_newline-check> |
| **Install** | `gem install puppet-lint-trailing_newline-check`               |
{: .table .table-condensed }

---

### variable_contains_upcase

> Extends puppet-lint to ensure that your variables are all lower case

| **URL**     | <https://github.com/fiddyspence/puppetlint-variablecase> |
| **Install** | `gem install puppet-lint-variable_contains_upcase`       |
{: .table .table-condensed }

---

### parameter_documentation

> Check to validate that all class parameters are documented.

| **URL**     | <https://github.com/domcleal/puppet-lint-param-docs> |
| **Install** | `gem install puppet-lint-param-docs`                 |
{: .table .table-condensed }

---

### roles_and_profiles

> Check to validate that your code matches to Roles&Profiles paradigm.

| **URL**     | <https://github.com/mcanevet/puppet-lint-roles_and_profiles-check> |
| **Install** | `gem install puppet-lint-roles_and_profiles-check`                 |
{: .table .table-condensed }

---

### absolute_template_path

> Check that template paths are relative not absolute.

| **URL**     | <https://github.com/deanwilson/puppet-lint-absolute_template_path-check> |
| **Install** | `gem install puppet-lint-absolute_template_path`                         |
{: .table .table-condensed }

---

### strict_indent

> Check that manifests follow a strict indent pattern

| **URL**     | <https://github.com/relud/puppet-lint-strict_indent-check> |
| **Install** | `gem install puppet-lint-strict_indent-check`              |
{: .table .table-condensed }

---

### unquoted_string

> Check that selectors and case statements cases are quoted

| **URL**     | <https://github.com/mcanevet/puppet-lint-unquoted_string-check> |
| **Install** | `gem install puppet-lint-unquoted_string-check`                 |
{: .table .table-condensed }

---

### package_ensure

> Check for packages with ensure set to latest.

| **URL**     | <https://github.com/danzilio/puppet-lint-package_ensure-check> |
| **Install** | `gem install puppet-lint-package_ensure-check`                 |
{: .table .table-condensed }

---


### reference syntax

> Check that resource references do not contain whitespace between resource reference and opening bracket and title does not start with capital letter.

| **URL**     | <https://github.com/voxpupuli/puppet-lint-resource_reference_syntax> |
| **Install** | `gem install puppet-lint-resource_reference_syntax`                  |
{: .table .table-condensed }

---


### top_scope_facts

> Check that facts are accessed using the $facts hash instead of as top scope variables. e.g use $facts['operatingsystem'] instead of $::operatingsystem

| **URL**     | <https://github.com/mmckinst/puppet-lint-top_scope_facts-check> |
| **Install** | `gem install puppet-lint-top_scope_facts-check`                 |
{: .table .table-condensed }


### legacy_facts

> Ensure facts are accessed using new structured facts. e.g use $facts['os']['name'] instead of $facts['operatingsystem']

| **URL**     | <https://github.com/mmckinst/puppet-lint-legacy_facts-check> |
| **Install** | `gem install puppet-lint-legacy_facts-check`                 |
{: .table .table-condensed }

---


### concatenated_template_files

> Ensure all template functions expand a file, rather than concatenating multiple templates string together.

| **URL**     | <https://github.com/deanwilson/puppet-lint-concatenated_template_files-check> |
| **Install** | `gem install puppet-lint-concatenated_template_files-check`                   |
{: .table .table-condensed }

---


### duplicate_class_parameters

> Ensures class parameter names are unique.

| **URL**     | <https://github.com/deanwilson/puppet-lint_duplicate_class_parameters-check> |
| **Install** | `gem install puppet-lint-duplicate_class_parameters-check`                   |
{: .table .table-condensed }

---


### yumrepo_gpgcheck_enabled

> Ensure gpgcheck is enabled on yumrepo resources

| **URL**     | <https://github.com/deanwilson/puppet-lint-yumrepo_gpgcheck_enabled-check> |
| **Install** | `gem install puppet-lint-yumrepo_gpgcheck_enabled-check`                   |
{: .table .table-condensed }

---


### no_cron_resources

> Ensure no cron resources are contained in the catalog.

| **URL**     | <https://github.com/deanwilson/puppet-lint-no_cron_resources-check> |
| **Install** | `gem install puppet-lint-no_cron_resources-check`                   |
{: .table .table-condensed }

---


###  world_writable_files

> Ensure file resources are not world writable.

| **URL**     | <https://github.com/deanwilson/puppet-lint-world_writable_files-check> |
| **Install** | `gem install puppet-lint-world_writable_files-check`                   |
{: .table .table-condensed }

---


### no_symbolic_file_modes

> Ensure all file resource modes are defined as octal values and not symbolic ones.

| **URL**     | <https://github.com/deanwilson/puppet-lint-no_symbolic_file_modes-check> |
| **Install** | `gem install puppet-lint-no_symbolic_file_modes-check`                   |
{: .table .table-condensed }

---


### no_erb_template

> Ensure there are no calls to the template() or inline_template() function as
> an aid to migrating to epp templates.

| **URL**     | <https://github.com/deanwilson/puppet-lint-no_erb_template-check> |
| **Install** | `gem install puppet-lint-no_erb_template-check`                   |
{: .table .table-condensed }

---


### no_file_path_attribute

> Ensure file resources do not have a path attribute.

| **URL**     | <https://github.com/deanwilson/puppet-lint-no_file_path_attribute-check> |
| **Install** | `gem install puppet-lint-no_file_path_attribute-check`                   |
{: .table .table-condensed }

---


### template_file_extension

> Ensure all file names used in `template` and `epp` functions end with the string '.erb' or '.epp' respectively.

| **URL**     | <https://github.com/deanwilson/puppet-lint-template_file_extension-check> |
| **Install** | `gem install puppet-lint-template_file_extension-check`   |
{: .table .table-condensed }

### racism_terminology

> Warn for uses of "racist" terms that you may want to stop using: master/slave, whitelist/blacklist.

| **URL**     | <https://github.com/tskirvin/puppet-lint-template_terminology-check> |
| **Install** | `gem install puppet-lint-racism_terminology-check`   |
{: .table .table-condensed }

