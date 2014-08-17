---
layout: default
title: right_to_left_relationship
sg: http://docs.puppetlabs.com/guides/style_guide.html#relationship-declarations
---

# Right To Left Relationship

---

Relationship declarations with the chaining syntax should only be used in the
“left to right” direction ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
Service['httpd'] <- Package['httpd']
{% endhighlight %}

#### What you should have done:
{% highlight text %}
Package['httpd'] -> Service['httpd']
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
