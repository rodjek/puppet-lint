---
layout: default
title: 140chars
sg: http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation-and-whitespace
---

# 140 character line limit

---

Your manifests should not contain any lines longer than 140 characters
([style guide]({{ page.sg }})).

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
