---
layout: default
title: variable_is_lowercase
sg: https://docs.puppet.com/guides/style_guide.html#variable-format
---

# Variable Format

---

When defining variables you must only use numbers, lowercase letters, and underscores. You should not use camelCasing, as it introduces inconsistency in style. ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
$packageName
{% endhighlight %}

#### What you should have done:
{% highlight text %}
$package_name
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
