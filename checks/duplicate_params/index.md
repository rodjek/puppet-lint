---
layout: default
title: duplicate_params
---

# Duplicate Parameters

---

You really shouldn't have duplicate parameters in a resource declaration, it is
going to lead to strangness.

#### What you have done
{% highlight text %}
file { '/tmp/foo':
  owner  => 'root',
  owner  => 'foo',
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
file { '/tmp/foo':
  owner  => 'root',
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
