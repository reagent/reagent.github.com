---
name: logging
language: TypeScript
featured: false
priority: 120
repository_url: https://github.com/reagent/logging
---

Some form of logging in applications is useful, but getting it set up correctly
and emitting structured logs can be a bit of a pain. I wrote this simple wrapper
around the [winston][] logging package to make that setup easier and allow it
to plug into tools like [Slonik][].

[winston]: https://github.com/winstonjs/winston
[Slonik]: https://github.com/gajus/slonik
