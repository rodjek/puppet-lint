---
layout: check
check:
  name: class_inherits_from_params_class
  title: Class Inherits From Params Class
  enabled: 'false'
  fix: false
---
{% include deprecation.html message="Puppet 2.6.x has been EOL for a long time now, so this check is
unnecessary." %}
The following popular method SHOULD NOT be used because it is not compatible
with Puppet 2.6.2 and earlier.

##### What you have done
{% highlight puppet %}
class ntp(
  $server = $ntp::params::server
) inherits ntp::params { }
{% endhighlight %}

##### What you should have done
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
