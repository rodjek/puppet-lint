---
layout: check
check:
  name: arrow_alignment
  title: Arrow Alignment
  enabled: 'true'
  fix: true
  style_guide: "#spacing-indentation-and-whitespace"
---
Arrows(`=>`) withing blocks of attributes (like resource declarations,
selectors, hashes, etc) should be aligned with the other arrows in that
block.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => present,
  mode => '0444',
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  ensure => present,
  mode   => '0444',
}
{% endhighlight %}
