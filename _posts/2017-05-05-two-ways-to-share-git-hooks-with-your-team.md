---
title: Two Ways to Share Git Hooks with Your Team
---

[Git hooks][1] are a useful feature that can be used to manage the integrity of
your source repository. On my current project, I wanted to ensure that all my Go
source files were formatted correctly before allowing them to be committed.

Fortunately for me, there is a [simple hook][2] available that I can save as
`.git/hooks/pre-commit` to make this happen.

This works well for my purposes, but I wanted to make it as simple as possible
when sharing with the rest of the team. [This Stack Overflow post][3] gives a
couple of possibilities that I'll go into more depth about.

### Create Your Managed Hooks Directory

Since the `.git` directory isn't versioned, I created `.githooks` at the root
where all these hooks live. You can choose whatever makes the most sense for
your project. Remember that when adding hooks they must be executable, so make
sure you `chmod +x` each of them to make that happen. Otherwise, you'll tear
your hair out when you think they should run but they don't.

### Choose Your Sharing Strategy

If you're using Git [version 2.9][4] or greater, this is as simple as setting
the `core.hooksPath` configuration variable to your managed hooks directory:

```
$ git config core.hooksPath .githooks
```

If you're using an earlier version, you need to ensure that your managed hooks
make it into the `.git/hooks` directory. I think symlinking is a good way to go,
just make sure to clear the old ones out first:

```
$ find .git/hooks -type l -exec rm {} \; && find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;
```

### Share With Your Team

That takes care of your local configuration, but each team member will need to
ensure the hooks are in the right place in their local repository each time they
do a new checkout. I like to just put this into my `Makefile` and include it
into my general project setup. Here are the two variations expressed as make
targets:

```
init:
  git config core.hooksPath .githooks
```

```
init:
  find .git/hooks -type l -exec rm {} \;
  find .githooks -type f -exec ln -sf ../../{} .git/hooks/ \;
```

---

_A version of this article first appeared on the [Viget][5] blog_

[1]: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
[2]: https://web.archive.org/web/20170404181131/https://golang.org/misc/git/pre-commit?m=text
[3]: https://stackoverflow.com/questions/427207/can-git-hook-scripts-be-managed-along-with-the-repository
[4]: https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.9.0.txt
[5]: https://www.viget.com/articles/two-ways-to-share-git-hooks-with-your-team/
