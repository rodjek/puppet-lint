---
layout: default
title: 80chars
sg: http://docs.puppetlabs.com/guides/style_guide.html#spacing-indentation-and-whitespace
---

# 80 character line limit

---

Your manifests should not contain any lines longer than 80 characters
([style guide]({{ page.sg }})).

** This check is disabled by default! **

## Enabling the check

To enable this check you can add `--{{ page.title }}-check` to your
`puppet-lint` command line.

{% highlight console %}
$ puppet-lint --{{ page.title }}-check path/to/file.pp
{% endhighlight %}

Alternatively, if you're calling puppet-lint via the Rake task, you should
insert the following line to your `Rakefile`.

{% highlight ruby %}
PuppetLint.configuration.send('enable_{{ page.title}}')
{% endhighlight %}
