---
name: Custom HTTP Routing
language: Go
featured: true
priority: 75
repository_url: https://gist.github.com/reagent/043da4661d2984e9ecb1ccb5343bf438
---

In the instances where using a third-party routing library is overkill, I wanted
to demonstrate some alternatives with varying degrees of complexity for how to
leverage the Go [`net/http`][net/http] package with [`ServeMux`][ServeMux] to
route requests to different handlers.

[net/http]: https://pkg.go.dev/net/http@go1.21.4
[ServeMux]: https://pkg.go.dev/net/http@go1.21.4#ServeMux
