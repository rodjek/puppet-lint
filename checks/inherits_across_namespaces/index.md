---
layout: default
title: inherits_across_namespaces
sg: http://docs.puppetlabs.com/guides/style_guide.html#class-inheritance
---

# Class Inheritance

---

Inheritance may be used within a module, but must not be used across module
namespaces. Cross-module dependencies should be satisfied in a more portable
way that doesn’t violate the concept of modularity, such as with include
statements or relationship declarations ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
class ssh inherits server { }

class ssh::client inherits workstation { }

class wordpress inherits apache { }
{% endhighlight %}

#### What you should have done:
{% highlight text %}
class ssh { }

class ssh::client inherits ssh { }

class ssh::server inherits ssh { }

class ssh::server::solaris inherits ssh::server { }
{% endhighlight %}

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
