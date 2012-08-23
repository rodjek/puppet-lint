---
layout: default
title: double_quoted_strings
sg: http://docs.puppetlabs.com/guides/style_guide.html#quoting
---

# Double Quoted Strings

All strings that do not contain variables or escape characters like `\n` or
`\t` should be enclosed in single quotes ([style guide]({{ page.sg }})).

#### What you have done
{% highlight puppet %}
  $foo = "bar"
{% endhighlight %}

#### What you should have done:
{% highlight puppet %}
  $foo = 'bar'
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
