---
layout: default
title: names_containing_dash
---

# Module Names Containing A Dash

Support for dashes in class and defined type names differs depending on the
release of Puppet you're running.  To ensure compatibility on all versions, you
should avoid using dashes.

#### What you have done
{% highlight text %}
class foo::bar-baz {}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
class foo::bar_baz
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
