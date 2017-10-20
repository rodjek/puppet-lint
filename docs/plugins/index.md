---
layout: nomenu
---
{:.page-title}
# Community Plugins

To use these plugins, add them to your `Gemfile` or install them at the system
level. You can then use/enable/disable them as you would with any built-in
check. Check the plugin's URL or more information on how to use its check(s).

{% for plugin in site.data.plugins %}

{:.section-title}
## {{ plugin.name }}

<blockquote class="blockquote">
    <p class="mb-0">{{ plugin.summary }}</p>
</blockquote>

<table class="table">
    <tbody>
        <tr>
            <th scope="row">URL</th>
            <td><a href="{{ plugin.url }}">{{ plugin.url }}</a></td>
        </tr>
        <tr>
            <th scope="row">Install</th>
            <td><code>gem install {{ plugin.gem }}</code></td>
        </tr>
    </tbody>
</table>

{% endfor %}
