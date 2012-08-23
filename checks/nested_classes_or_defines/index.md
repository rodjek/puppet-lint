---
layout: default
title: nested_classes_or_defines
sg: http://docs.puppetlabs.com/guides/style_guide.html#classes-and-defined-resource-types-within-classes
---

# Nested Classes Or Defines

Classes and defined resource types must not be defined within other classes
([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
class apache {
  class ssl { }
}

# or

class apache {
  define config() { }
}
{% endhighlight %}

#### What you should have done:
Split these classes and/or defines out into seperate files as described in the
[module fundamentals
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
