---
layout: check
check:
  name: single_quote_string_with_variables
  title: Single Quote String With Variables
  enabled: 'true'
  fix: false
  style_guide: "#quoting"
---
Single quoted strings do not get interpolated, so you should not attempt to
embed variables in one. This is not a style issue, rather a common mistake.

##### What you have done
{% highlight puppet %}
$foo = 'bar ${baz}'
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$foo = "bar ${baz}"
{% endhighlight %}
