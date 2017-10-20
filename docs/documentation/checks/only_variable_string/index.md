---
layout: check
check:
  name: only_variable_string
  title: Only Variable String
  enabled: 'true'
  fix: true
  style_guide: "#quoting"
---
Variables standing by themselves should not be quoted. To put it another way,
strings should not contain just a single variable.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  owner => "${file_owner}",
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  owner => $file_owner,
}
{% endhighlight %}
