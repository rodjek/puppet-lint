---
layout: default
title: trailing_whitespace
sg: http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation--whitespace
---

# Trailing whitespace

Your manifests must not contain any trailing whitespace on any line
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
