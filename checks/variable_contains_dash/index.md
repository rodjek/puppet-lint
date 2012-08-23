---
layout: default
title: variable_contains_dash
sg: http://docs.puppetlabs.com/guides/style_guide.html#variable-format
---

# Variable Format

When defining variables you should only use letters, numbers and underscores.
You should specifically not make use of dashes ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
$foo-bar
{% endhighlight %}

#### What you should have done:
{% highlight text %}
$foo_bar
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
