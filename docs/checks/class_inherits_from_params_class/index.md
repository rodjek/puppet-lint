---
layout: default
title: class_inherits_from_params_class
sg: http://docs.puppetlabs.com/guides/style_guide.html#class-parameter-defaults
---

# Parameterised class inheritings from 'params' class

---

The following popular method SHOULD NOT be used because it is not
compatible with Puppet 2.6.2 and earlier.

#### What you have done
{% highlight text %}
class ntp(
  $server = $ntp::params::server
) inherits ntp::params { }
{% endhighlight %}

#### What you should have done:
{% highlight text %}
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
