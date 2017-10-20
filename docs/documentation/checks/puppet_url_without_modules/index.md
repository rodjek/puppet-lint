---
layout: check
check:
  name: puppet_url_without_modules
  title: Puppet Url Without Modules
  enabled: 'true'
  fix: true
---
When using puppet:// URLs, you should ensure that the path starts with
`modules/` (as the most common mount point in the Puppet fileserver).

##### What you have done
{% highlight puppet %}
file { '/etc/apache/apache2.conf':
  source => 'puppet:///apache/etc/apache/apache2.conf',
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/etc/apache/apache2.conf':
  source => 'puppet:///modules/apache/etc/apache/apache2.conf',
}
{% endhighlight %}
