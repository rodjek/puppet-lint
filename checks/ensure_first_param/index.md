---
layout: default
title: ensure_first_param
sg: http://docs.puppetlabs.com/guides/style_guide.html#attribute-ordering
---

# Attribute Ordering

If a resource declaration includes an `ensure` parameter, it should be the
first parameter specified ([style guide]({{ page.sg }})).

#### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  owner  => 'root',
  group  => 'root',
  ensure => present,
}
{% endhighlight %}

#### What you should have done:
{% highlight puppet %}
file { '/tmp/foo':
  ensure => present,
  owner  => 'root',
  group  => 'root',
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
