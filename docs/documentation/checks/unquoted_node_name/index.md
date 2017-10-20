---
layout: check
check:
  name: unquoted_node_name
  title: Unquoted Node Name
  enabled: 'true'
  fix: true
---
Node names should be one of the following:

 * A quoted string
 * The bare word `default`
 * A regular expression

##### What you have done
{% highlight puppet %}
node server1 { }
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
node 'server1' { }
{% endhighlight %}
