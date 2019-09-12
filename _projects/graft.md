---
name: Graft
language: Ruby
featured: false
priority: 2
repository_url: https://github.com/reagent/graft
---

After working with a variety of APIs, I had the idea of making a simple
translation layer with a DSL that could seamlessly map attributes from either
XML or JSON response payloads.  I didn't pursue the idea far enough to run into
any complicated edge cases, but it was a good introduction to designing a DSL to
solve a real problem I was facing. You can tell the age of the project as it
uses [hpricot](https://github.com/hpricot/hpricot) for parsing XML, rather than
a more modern solution like [Nokogiri](https://github.com/sparklemotion/nokogiri).
