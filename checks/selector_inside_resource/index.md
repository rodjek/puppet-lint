---
layout: default
title: selector_inside_resource
sg: http://docs.puppetlabs.com/guides/style_guide.html#keep-resource-declarations-simple
---

# Selector Inside A Resource

---

You should not intermingle conditionals with resource declarations. When using
conditionals for data assignment, you should separate conditional code from the
resource declarations ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
file { '/tmp/readme.txt':
  mode => $::operatingsystem ? {
    debian => '0777',
    redhat => '0776',
    fedora => '0007',
  }
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
$file_mode = $::operatingsystem ? {
  debian => '0007',
  redhat => '0776',
  fedora => '0007',
}

file { '/tmp/readme.txt':
  mode => $file_mode,
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
