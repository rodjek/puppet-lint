---
layout: check
check:
  name: variable_contains_dash
  title: Variable Contains Dash
  enabled: 'true'
  fix: false
  style_guide: "#variable-format"
---
When defining variables you should only use letters, numbers and underscores.
You should specifically not make use of dashes.

##### What you have done
{% highlight puppet %}
$foo-bar
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$foo_bar
{% endhighlight %}
