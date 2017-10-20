---
layout: check
check:
  name: hard_tabs
  title: Hard Tabs
  enabled: 'true'
  fix: true
  style_guide: "#spacing-indentation-and-whitespace"
---
In order to comply with the style guide, manifests must not use hard tab
characters (\t) in the whitespace.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
        ensure => present,
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo'::
  ensure => present,
}
{% endhighlight %}
