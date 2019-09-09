---
title: Software
header: Software
---

A collection of selected software projects that I've created that I think are
worth highlighting.  Additional projects can be found on my
[Github profile](https://github.com/reagent).

[**Fleakr**](https://github.com/reagent/fleakr) (Ruby)
: My first serious effort at creating a reusable software library which
represents a departure from the constraints of Rails to really dive deep into
some core principles of object oriented design. There are some "clever" spots in
the code that I don't think I would repeat if I were to approach this problem
domain again, but there's a lot of good composition and delegation of
responsibility in how this code is designed and implemented.

[**Graft**](https://github.com/reagent/graft) (Ruby)
: After working with a variety of APIs, I had the idea of making a simple
translation layer with a DSL that could seamlessly map attributes from either
XML or JSON response payloads.  I didn't pursue the idea far enough to run into
any complicated edge cases, but it was a good introduction to designing a DSL to
solve a real problem I was facing. You can tell the age of the project as it
uses [hpricot](https://github.com/hpricot/hpricot) for parsing XML, rather than
a more modern solution like [Nokogiri](https://github.com/sparklemotion/nokogiri).

[**dnsimple**](https://github.com/vigetlabs/dnsimple) (Python)
: I had been using the dnsimple Ansible module to manage DNS records when
creating and destroying servers, but the underlying Python module became out of
sync with the way that Ansible was trying to interact with it.  I set about
updating the code to handle the new API endpoints and structure the code in a
way that maximized usability and modularity with an eye to supporting the
updated API version. While this never became the canonical Python module for
DNSimple, some ideas were ported to the
[official module](https://github.com/onlyhavecans/dnsimple-python).

[**Geocoder**](https://github.com/reagent/geocoder) (Ruby)
: A short-lived attempt at creating a near-zero dependency geocoding library. I
don't think I ever used it in an actual project, but my reliance only on the
basic HTTP functionality available in the Ruby standard library is a theme that
can be found in other API clients that I continue to write.  While `Net:HTTP` is
cumbersome to use for more complex use cases, it's usually a sufficient tool.

[**TestFS**](https://github.com/reagent/test-fs) (Ruby)
: It was sometimes difficult to manage fixtures for tests that required
filesystem access. This was a solution to set up and tear down required files on
a per-test basis.  It was a fun DSL to work on that was definitely inspired by
[builder](https://github.com/jimweirich/builder).

[**http**](https://github.com/reagent/http) (C)
: This one is a bizarre sleeper hit. In revisiting the C programming language, I
was interested in exploring how to handle low-level socket connections which
resulted in this basic, mostly non-functional HTTP library. This is currently my
most popular project on Github for reasons that are unknown to me.

[**copyright**](https://github.com/reagent/copyright) (Go)
: A bit tongue-in-cheek, this is a very simple **_nanoservice_** written in Go.
It's a good example of a basic HTTP service that can interact with a SQLite
database and contains some very basic regex-based URL multiplexing.

[**minecraft-server**](https://github.com/reagent/minecraft-server) (Ansible)
: After experiencing lag on our outdated home computers when using
"Open to LAN", I took some time to pull together an existing Ansible role to
create an on-demand Minecraft server on Digital Ocean.  I experimented a bit
with using [Block Storage](https://www.digitalocean.com/products/block-storage/)
to store world data, but moved to persisting data in a
[Space](https://www.digitalocean.com/products/spaces/) to allow for a
multi-server setup.
