---
name: resume-generator
language: TypeScript
featured: true
priority: 50
repository_url: https://github.com/reagent/resume-generator
---

I had been using [PDFKit][] and Ruby to generate PDF versions of my résumé from
a collection of Markdown documents, but it seemed like every time I went to
update the content and regenerate the document the formatting would be vastly
different. After some research, I decided to ditch PDFKit and use [Puppeteer][]
to implement the Markdown → HTML → PDF pipeline with much better results.

[PDFKit]: https://github.com/pdfkit/pdfkit
[Puppeteer]: https://pptr.dev/
