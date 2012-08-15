---
layout: default
title: 2sp_soft_tabs
sg: http://docs.puppetlabs.com/guides/style_guide.html#
---

# 2 Space Soft Tabs

In order to comply with the style guide, manifests must use 2 space characters
when indenting ([style guide]({{ page.sg }})).

#### What you have done
{% highlight puppet %}
file { '/tmp/foo':
    ensure => present,
}
{% endhighlight %}

#### What you should have done:
{% highlight puppet %}
file { '/tmp/foo':
  ensure => present,
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
