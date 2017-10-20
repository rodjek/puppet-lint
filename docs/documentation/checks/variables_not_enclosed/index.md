---
layout: check
check:
  name: variables_not_enclosed
  title: Variables Not Enclosed
  enabled: 'true'
  fix: true
  style_guide: "#quoting"
---
All variables should be enclosed in braces (`{}`) when being interpolated in
a string.

##### What you have done
{% highlight puppet %}
$foo = "bar $baz"
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$foo = "bar ${baz}"
{% endhighlight %}
