---
layout: default
title: ensure_not_symlink_target
sg: http://docs.puppetlabs.com/guides/style_guide.html#symbolic-links
---

# Ensure Parameter Not A Symlink Target

In the interest of clarity, symbolic links should be declared by using an
ensure value of `ensure => link` and explicitly specifying a value for the
`target` attribute.  Using a path to the target as the ensure value is not
recommended ([style guide]({{ page.sg }})).

#### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => '/tmp/bar',
}
{% endhighlight %}

#### What you should have done:
{% highlight puppet %}
file { '/tmp/foo':
  ensure => link,
  target => '/tmp/bar',
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
