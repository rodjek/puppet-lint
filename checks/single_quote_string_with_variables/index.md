---
layout: default
title: single_quote_string_with_variables
---

# Single Quoted String Containing Variables

Single quoted strings do not get interpolated, so you should not attempt to
embed variables in one.  This is not a style issue, rather a common mistake.

#### What you have done
{% highlight text %}
  $foo = 'bar ${baz}'
{% endhighlight %}

#### What you should have done:
{% highlight text %}
  $foo = "bar ${baz}"
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
