---
layout: check
check:
  name: 2sp_soft_tabs
  title: 2sp Soft Tabs
  enabled: 'true'
  fix: false
  style_guide: "#spacing-indentation-and-whitespace"
---
In order to comply with the style guide, manifests must use 2 space
characters when indenting.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
    ensure => present,
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => present,
}
{% endhighlight %}
