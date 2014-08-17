---
layout: default
title: documentation
sg: http://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
---

# Documentation

---

All Puppet classes and defines should be documented via comments directly above
the start of the code ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
class ntp {}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
# Install and configure an NTP server
# You should feel free to expand on this and document any parameters etc
class ntp {}
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
