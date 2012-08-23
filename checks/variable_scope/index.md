---
layout: default
title: variable_scope
sg: http://docs.puppetlabs.com/guides/style_guide.html#namespacing-variables
---

# Namespacing Variables

When using top-scope variables, including facts, Puppet modules should
explicitly specify the empty namespace to prevent accidental scoping issues.
([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
$operatingsystem
{% endhighlight %}

#### What you should have done:
{% highlight text %}
$::operatingsystem
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
