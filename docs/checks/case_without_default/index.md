---
layout: default
title: case_without_default
sg: http://docs.puppetlabs.com/guides/style_guide.html#defaults-for-case-statements-and-selectors
---

# Case Without A Default Option

---

Case statements should have default cases. Additionally, the default case
should fail the catalog compilation when the resulting behavior cannot be
predicted on the majority of platforms the module will be used on. If you want
the default case to be “do nothing,” include it as an explicit `default: {}`
for clarity’s sake ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
case $::operatingsystem {
  centos: {
    $version = '1.2.3'
  }
  solaris: {
    $version = '3.2.1'
  }
}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
case $::operatingsystem {
  centos: {
    $version = '1.2.3'
  }
  solaris: {
    $version = '3.2.1'
  }
  default: {
    fail("Module ${module_name} is not supported on ${::operatingsystem}")
  }
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
