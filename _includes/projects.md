{% for project in include.projects %}
[**{{ project.name }}**]({{ project.repository_url }}) ({{ project.language }})
: {{ project.content }}
{%- endfor -%}
