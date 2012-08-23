---
layout: default
title: parameter_order
sg: http://docs.puppetlabs.com/guides/style_guide.html#display-order-of-class-parameters
---

# Display Order Of Parameters

In parameterized class and defined resource type declarations, parameters that
are required should be listed before optional parameters (i.e. parameters with
defaults) ([style guide]({{ page.sg }})).

#### What you have done
{% highlight text %}
class ntp (
  $options   = "iburst",
  $servers,
  $multicast = false
) {}
{% endhighlight %}

#### What you should have done:
{% highlight text %}
class ntp (
  $servers,
  $options   = "iburst",
  $multicast = false
) {}
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
