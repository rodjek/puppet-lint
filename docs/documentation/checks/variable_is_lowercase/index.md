---
layout: check
check:
  name: variable_is_lowercase
  title: Variable Is Lowercase
  enabled: 'true'
  fix: false
  style_guide: "#variable-format"
---
When defining variables you must only use numbers, lowercase letters and
underscores. You should not use camelCasing, as it introduces inconsistency
in style.

##### What you have done
{% highlight puppet %}
$packageName
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$package_name
{% endhighlight %}
