---
layout: default
title: class_parameter_defaults
sg: http://docs.puppetlabs.com/guides/style_guide.html#class-parameter-defaults
---

# Class Parameter Defaults

When writing a module that accepts class parameters sane defaults SHOULD be
provided for optional parameters to allow the end user the option of not
explicitly specifying the parameter when declaring the class
([style guide]({{ page.sg }})).

#### What you have done
{% highlight puppet %}
class ntp(
 $server,
) {}
{% endhighlight %}

#### What you should have done:
{% highlight puppet %}
class ntp(
  $server = 'UNSET'
) {

  include ntp::params

  $server_real = $server ? {
    'UNSET' => $::ntp::params::server,
    default => $server,
  }
}
{% endhighlight %}

The following popular alternative method SHOULD NOT be used because it is not
compatible with Puppet 2.6.2 and earlier.

#### What you have done
{% highlight puppet %}
class ntp(
  $server = $ntp::params::server
) inherits ntp::params { }
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
