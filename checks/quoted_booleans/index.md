---
layout: default
title: quoted_booleans
---

# Quoted Booleans

Boolean values (`true` and `false`) behave differently when quoted (`'true'`
and `'false'`), which can lead to a fair bit of confusion.  As a general rule,
you should never quote booleans.  This is not a style issue, rather a common
mistake.

#### What you have done
{% highlight text %}
  file { '/tmp/foo':
    purge => 'true',
  }
{% endhighlight %}

#### What you should have done:
{% highlight text %}
  file { '/tmp/foo':
    purge => true,
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
