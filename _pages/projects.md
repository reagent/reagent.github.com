---
title: Projects
header: Software Projects
---

A collection of selected software projects that I've created that I think are
worth highlighting.  Additional projects can be found on my
[Github profile](https://github.com/reagent).

{% assign projects = site.projects | sort:'priority' %}
{% include projects.md projects=projects %}
