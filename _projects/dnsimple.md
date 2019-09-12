---
name: dnsimple
language: Python
featured: true
priority: 3
repository_url: https://github.com/vigetlabs/dnsimple
---

I had been using the dnsimple Ansible module to manage DNS records when creating
and destroying servers, but the underlying Python module became out of sync with
the way that Ansible was trying to interact with it.  I set about updating the
code to handle the new API endpoints and structure the code in a way that
maximized usability and modularity with an eye to supporting the updated API
version. While this never became the canonical Python module for DNSimple, some
ideas were ported to the
[official module](https://github.com/onlyhavecans/dnsimple-python).
