---
layout: check
check:
  name: documentation
  title: Documentation
  enabled: 'true'
  fix: false
  style_guide: "#public-and-private"
---
All Puppet classes and defines should be documented via comments directly
above the start of the code.

##### What you have done
{% highlight puppet %}
class ntp {}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
# Install and configure an NTP server
# You should feel free to expand on this and document any parameters etc
class ntp {}
{% endhighlight %}
