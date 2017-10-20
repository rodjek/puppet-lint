---
layout: check
check:
  name: arrow_on_right_operand_line
  title: Arrow On Right Operand Line
  enabled: 'true'
  fix: true
  style_guide: "#chaining-arrow-syntax"
---
A chain operator (`->`, `<-`, `~>`, or `<~`) should appear on the same line
as its right-hand operand.

##### What you have done
{% highlight puppet %}
Service['httpd'] ->
Package['httpd']
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
Package['httpd']
-> Service['httpd']
{% endhighlight %}
