---
layout: default
title: puppet_url_without_modules
---

# puppet:// URL without modules/

---

When using puppet:// URLs, you should ensure that the path starts with
`modules/` (as the most commonly used mount point in the Puppet fileserver).

#### What you have done
{% highlight text %}
file { '/etc/apache/apache2.conf':
  source => 'puppet:///apache/etc/apache/apache2.conf',
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
file { '/etc/apache/apache2.conf':
  source => 'puppet:///modules/apache2/etc/apache/apache2.conf',
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
