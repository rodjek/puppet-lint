---
layout: default
title: autoloader_layout
sg: http://docs.puppetlabs.com/guides/style_guide.html#separate-files
---

# Manifest Files In The Proper Layout

All classes and resource type definitions must be in separate files in the
manifests directory of their module.  This is functionally identical to
declaring all classes and defines in init.pp, but highlights the structure of
the module and makes everything more legible ([style guide]({{ page.sg }})).

Additionally, the files should be named appropriately for the class or defined
type they contain.  `class foo` should be in `foo/manifests/init.pp`, `class
foo::bar` should be in `foo/manifests/bar.pp` and so on.  You can read more
about the filesystem layout for modules in the [module fundamentals
documentation](http://docs.puppetlabs.com/puppet/2.7/reference/modules_fundamentals.html#module-layout).

## Disabling the check

To disable this check you can add `--no-{{ page.title }}-check` to your
`puppet-lint` command line.

{% highlight console %}
$ puppet-lint --no-{{ page.title }}-check path/to/file.pp
{% endhighlight %}

Alternatively, if you're calling puppet-lint via the Rake task, you should
insert the following line to your `Rakefile`.

{% highlight ruby %}
PuppetLint.configuration.send('disable_{{ page.title}}')
{% endhighlight %}
