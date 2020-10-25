---
title: Articles
header: Articles
---

Articles I've written on various technical topics, mostly related to software
development:

{% assign posts = site.posts %}
{% if site.show_drafts != true %}
  {% assign posts = posts | where:'draft',false %}
{% endif %}

{% assign articles = site.articles | concat: posts | sort:'date' | reverse %}
{% include articles.html articles=articles %}
