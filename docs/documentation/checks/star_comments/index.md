---
layout: check
check:
  name: star_comments
  title: Star Comments
  enabled: 'true'
  fix: true
  style_guide: "#comments"
---
Although the Puppet language allows you to use `/* */` style multiline
comments, it is recommended that you use multiple `#` style comments instead.

##### What you have done
{% highlight puppet %}
/* my awesome comment that describes
 * exactly what I'm trying to do */
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
# my awesome comment that describes
# exactly what I'm trying to do
{% endhighlight %}
