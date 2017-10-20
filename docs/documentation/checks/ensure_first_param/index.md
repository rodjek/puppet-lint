---
layout: check
check:
  name: ensure_first_param
  title: Ensure First Param
  enabled: 'true'
  fix: true
  style_guide: "#attribute-ordering"
---
If a resource declaration includes an `ensure` parameter, it should be the
first parameter specified.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  owner  => 'root',
  group  => 'root',
  ensure => present,
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => present,
  owner  => 'root',
  group  => 'root',
}
{% endhighlight %}
