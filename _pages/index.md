---
title: Home
header: About
---

I'm an experienced software engineer specializing in back-end technologies with
expertise in architecting well-designed software applications. I bring more
than two decades of hands-on experience helping organizations bring their
products to market while improving their development and delivery processes.

To better understand my work and approach, please check out my
[projects](/software), view my
[résumé](/resume)([pdf](/assets/files/resume-patrick-reagan.pdf)), or send me an
[email](mailto:patrick@the-reagans.com?subject=I'm%20your%20biggest%20fan).

## Featured Software Projects

{% assign projects = site.projects | where:'featured',true | sort:'priority' %}
{% include projects.md projects=projects %}

[more projects](/projects)

## Recent Articles

{% assign posts = site.posts %}
{% if site.show_drafts != true %}
  {% assign posts = posts | where:'draft',false %}
{% endif %}

{% assign articles = site.articles | concat: posts | sort:'date' | reverse %}
{% include articles.md articles=articles limit=10 %}

[more articles](/articles)
