---
layout: check
check:
  name: double_quoted_strings
  title: Double Quoted Strings
  enabled: 'true'
  fix: true
  style_guide: "#quoting"
---
All strings that do not contain variables or escape characters like `\n` or
`\t` should be enclosed in single quotes.

##### What you have done
{% highlight puppet %}
$foo = "bar"
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$foo = 'bar'
{% endhighlight %}
