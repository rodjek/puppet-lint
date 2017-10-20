---
layout: check
check:
  name: unquoted_file_mode
  title: Unquoted File Mode
  enabled: 'true'
  fix: true
  style_guide: "#file-modes"
---
File modes should be specified as single-quoted strings instead of bare word
numbers.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  mode => 0666,
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  mode => '0666',
}
{% endhighlight %}
