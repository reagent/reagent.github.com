{%- for article in include.articles limit:include.limit -%}
  * [{{ article.title }}]({{ article.source_url | default: article.url }}) ({{ article.date | date:'%B %Y'}})
{% endfor %}