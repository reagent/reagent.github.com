---
title: Home
---

I'm an experienced software engineer specializing in back-end technologies with
expertise in architecting well-designed software applications. I bring more
than two decades of hands-on experience helping organizations bring their
products to market while improving their development and delivery processes.

To better understand my work and approach, please check out my
[projects][1], view my [résumé][2], or send me an [email][3].

## Featured Software Projects

{% assign projects = site.projects | where:'featured',true | sort:'priority' %}
{% include projects.html projects=projects %}

[more projects](/projects)

## Recent Articles

{% assign posts = site.posts %}
{% if site.show_drafts != true %}
  {% assign posts = posts | where:'draft',false %}
{% endif %}

{% assign articles = site.articles | concat: posts | sort:'date' | reverse %}
{% include articles.html articles=articles limit=10 %}

[more articles](/articles)

[1]: {{ 'projects' | relative_url }}
[2]: {{ 'resume' | relative_url  }}
[3]: mailto:patrick@the-reagans.com?subject=I'm%20your%20biggest%20fan