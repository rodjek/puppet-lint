---
layout: check
check:
  name: slash_comments
  title: Slash Comments
  enabled: 'true'
  fix: true
  style_guide: "#comments"
---
Although the Puppet language allows you to use `//` style comments, it is
recommended that you use `#` style comments.

##### What you have done
{% highlight puppet %}
// my awesome comment
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
# my awesome comment
{% endhighlight %}
