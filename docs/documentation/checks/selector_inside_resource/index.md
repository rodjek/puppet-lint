---
layout: check
check:
  name: selector_inside_resource
  title: Selector Inside Resource
  enabled: 'true'
  fix: false
  style_guide: "#keep-resource-declarations-simple"
---
You should not intermingle conditionals with resource declarations. When
using conditionals for data assignment, you should separate conditional code
from the resource declarations.

##### What you have done
{% highlight puppet %}
file { '/tmp/readme.txt':
  mode => $::operatingsystem ? {
    debian => '0777',
    redhat => '0776',
    fedora => '0007',
  }
}
{% endhighlight %}

##### What you should have done
{% highlight puppet %}
$file_mode = $::operatingsystem ? {
  debian => '0777',
  redhat => '0776',
  fedora => '0007',
}

file { '/tmp/readme.txt':
  mode => $file_mode,
}
{% endhighlight %}
