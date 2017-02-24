---
layout: default
title: names_containing_uppercase
---

# Module Names Containing Uppercase

---

Support for uppercase characters in class and defined type names differs depending on the release of Puppet you're running.
To ensure compatibility on all versions, you should avoid using uppercase.

#### What you have done
{% highlight text %}
class Foo::BarBaz {}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
class foo::barbaz
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
