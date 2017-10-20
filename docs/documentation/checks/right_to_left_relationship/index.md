---
layout: check
check:
  name: right_to_left_relationship
  title: Right To Left Relationship
  enabled: 'true'
  fix: false
  style_guide: "#chaining-arrow-syntax"
---
Relationship declarations with the chaining syntax should only be used in the
"left to right" direction.

##### What you have done
{% highlight puppet %}
Service['httpd'] <- Package['httpd']
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
Package['httpd'] -> Service['httpd']
{% endhighlight %}
