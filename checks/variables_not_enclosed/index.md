---
layout: default
title: variables_not_enclosed
sg: http://docs.puppetlabs.com/guides/style_guide.html#quoting
---

# Variables Not Enclosed

---

All variables should be enclosed in in braces (`{}`) when being interpolated in
a string ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
  $foo = "bar $baz"
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
