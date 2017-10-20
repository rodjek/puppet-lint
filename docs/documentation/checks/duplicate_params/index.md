---
layout: check
check:
  name: duplicate_params
  title: Duplicate Params
  enabled: 'true'
  fix: false
---
You really should not have duplicate parameters in a resource declaration, it
is going to lead to strangeness.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  owner => 'root',
  owner => 'roo',
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  owner => 'root',
}
{% endhighlight %}
