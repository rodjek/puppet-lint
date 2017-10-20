---
layout: check
check:
  name: unquoted_resource_title
  title: Unquoted Resource Title
  enabled: 'true'
  fix: true
  style_guide: "#resource-names"
---
All resource titles should be quoted.

##### What you have done
{% highlight puppet %}
service { apache:
  ensure => running,
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
service { 'apache':
  ensure => running,
}
{% endhighlight %}
