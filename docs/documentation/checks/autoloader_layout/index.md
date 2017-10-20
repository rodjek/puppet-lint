---
layout: check
check:
  name: autoloader_layout
  title: Autoloader Layout
  enabled: 'true'
  fix: false
  style_guide: "#separate-files"
---
All classes and resource type definitions must be in separate files in the
manifests directory of their module. This is functionally identical to
declaring all classes and defines in `init.pp`, but highlights the structure
and makes everything more legible.

Additionally, the files should be named appropriately for the class or
defined type they contain. `class foo` should be in `foo/manifests/init.pp`,
`class foo::bar` should be in `foo/manifests/bar.pp` and so on. You can read
more about the filesystem layout for modules in the [module fundamentals
documentation](https://puppet.com/docs/puppet/latest/modules_fundamentals.html#module-layout).
