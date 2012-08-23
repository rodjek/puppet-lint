---
layout: default
title: file_mode
sg: http://docs.puppetlabs.com/guides/style_guide.html#file-modes
---

# File Modes

File modes should be represented as 4 digits rather than 3, to explicitly show
that they are octal values.  File modes can also be represented symbolically
e.g. `u=rw,g=r` ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
file { '/tmp/foo':
  mode => '666',
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
file { '/tmp/foo':
  mode => '0666',
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
