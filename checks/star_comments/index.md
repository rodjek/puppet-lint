---
layout: default
title: star_comments
sg: http://docs.puppetlabs.com/guides/style_guide.html#comments
---

# Slash-asterisk comments

Although the Puppet language allows you to use `/* */` style multiline
comments, it is recommended that you use multiple `#` style comments instead
([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
  /* my awesome comment that describes
   * exactly what I'm trying to do */
{% endhighlight %}

#### What you should have done:
{% highlight text %}
  # my awesome comment that describes
  # exactly what I'm trying to do
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
