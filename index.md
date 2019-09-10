---
title: Home
header: About
---

I'm an experienced software engineer specializing in back-end technologies with
expertise in architecting well-designed software applications. I bring more
than two decades of hands-on experience helping organizations bring their
products to market while improving their development and delivery processes.

To better understand my work and approach, please check out my
[projects](/software), view my [résumé](/resume)([pdf](/files/resume-patrick-reagan.pdf)), or send me an [email](mailto:patrick@the-reagans.com?subject=I'm%20your%20biggest%20fan).

## Recent Articles

{% assign articles = site.articles | sort:'date' | reverse %}
{%- for article in articles | limit:10 -%}
* [{{ article.title }}]({{ article.source_url }}) ({{ article.date | date:'%B %Y'}})
{% endfor %}


[more articles](/articles)
