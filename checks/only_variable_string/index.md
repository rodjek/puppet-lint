---
layout: default
title: only_variable_string
sg: http://docs.puppetlabs.com/guides/style_guide.html#quoting
---

# Only Variable String

---

Variables standing by themselves should not be quoted.  To put it another way,
strings should not contain just a single variable
([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
  file { '/tmp/foo':
    owner => "${file_owner}",
  }
{% endhighlight %}

#### What you should have done:
{% highlight text %}
  file { '/tmp/foo':
    owner => $file_owner,
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
