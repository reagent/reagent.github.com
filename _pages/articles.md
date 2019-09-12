---
title: Articles
header: Articles
---

Articles I've written on various technical topics, mostly related to software
development:

{% assign articles = site.articles | sort: 'date' | reverse %}
{% include articles.md articles=articles %}
