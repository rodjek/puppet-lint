---
layout: check
check:
  name: file_mode
  title: File Mode
  enabled: 'true'
  fix: true
  style_guide: "#file-modes"
---
File modes should be represented as 4 digits rather than 3, to explicitly
show that they are octal values. File modes can also be represented
symbolically e.g.g `u=rw,g=r`.

##### What you have done
{% highlight puppet %}
file { '/tmp/foo':
  mode => '666',
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
file { '/tmp/foo':
  mode => '0666',
}
{% endhighlight %}
