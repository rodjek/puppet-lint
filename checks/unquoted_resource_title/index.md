---
layout: default
title: unquoted_resource_title
sg: http://docs.puppetlabs.com/guides/style_guide.html#resource-names
---

# Unquoted Resource Titles

All resource titles should be quoted ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
service { apache:
  ensure => running,
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
service { 'apache':
  ensure => running,
}
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
