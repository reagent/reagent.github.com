---
title: Git Worktrees as Swimlanes
---

Git worktrees let you have multiple branches checked out at the same time,
which is genuinely useful — but the advice you usually hear ("one worktree per
feature branch") leaves you juggling a pile of ephemeral directories, each one
missing the `.env` file, the `node_modules`, or the install step that makes it
runnable. That friction keeps most people on a single checkout.

Here's a different way to use worktrees: as **persistent roles**, not
per-feature containers.

## The Mental Flip

A worktree is a _directory with a role_. The directory stays put; whichever
branch I need rotates through it.

I open each one in its own VS Code window, so switching swimlanes is a
window switch. Once I'm in a swimlane, I pick the branch with `git
checkout`.

That's it. The rest of this post is about how to make that comfortable in
practice.

## The Swimlanes I Use

I keep four worktrees around at all times for any repo I spend real time in:

| Swimlane      | Role                                                                                                       |
| ------------- | ---------------------------------------------------------------------------------------------------------- |
| `development` | Stays on the `development` branch. Used to run the latest version of the app and as the base I branch off. |
| `work-queue`  | Where I create new branches for each ticket I work on.                                                     |
| `review`      | Where I check out whatever branch is currently under review.                                               |
| `experiments` | Longer-running spikes that may or may not produce commits.                                                 |

`development` and `experiments` are stable: the branch checked out in each one
rarely changes. `work-queue` and `review` are different — the _directory_ is
stable, but the branch checked out inside it rotates constantly.

Set them up once. Clone your repo into a directory you'll treat as the main
checkout — I name mine after the default branch (`development`), but any name
works. Then add the rest as siblings:

```
$ git clone <repo-url> ~/Projects/<project>/<main-checkout>
$ cd ~/Projects/<project>/<main-checkout>
$ git worktree add ../work-queue
$ git worktree add ../review
$ git worktree add ../experiments
```

Without a branch argument, `git worktree add` creates a new branch named
after the directory (so `../work-queue` gets a branch called `work-queue`)
off HEAD. I never commit to these — they exist only so the worktree has
_some_ branch to initialize with. The real work happens on branches I check
out into the directory later.

## Rotating Branches Through a Directory

When a new task comes in, I switch to my `work-queue` window and check
out a fresh branch off `development`:

```
$ git fetch origin
$ git checkout -b TICKET-1234-fix-login origin/development
```

That's the whole ceremony. The directory doesn't care what branch it hosts.
When the work is done and the PR is opened, I leave the branch where it is and
move on to the next one — `git checkout -b TICKET-1235-...` — and the previous
branch keeps living on the remote.

`review` works the same way, but the branches it hosts already exist. When a
PR lands in my review queue, I switch to the `review` window and pull it in:

```
$ git fetch origin
$ git checkout TICKET-1234-fix-login
```

I review in the directory, make any fixup commits directly, push, and when
I'm done I rotate to the next PR. No new worktrees to create, no old ones to
clean up.

In practice I let an agent run most of these commands for me — the mechanics
are identical, just wrapped in a slash command. The next post in this series
covers that layer.

## Solving the Untracked-File Tax

The real reason worktrees feel painful is untracked files. A new worktree is
a fresh checkout — no `.env`, no installed dependencies, no local config.
Before you can run anything, you're copying files by hand or re-running setup
scripts.

I had [Claude Code][claude-code] write a small git subcommand called
[`git worktree-copy`][worktree-copy] that handles this. It wraps `git worktree add` and, after the new worktree is
created, reads a `.worktree-copy` file from the repo root to decide what to
copy or run. The config is plain text:

```
# Files and directories to copy from the source checkout
.env
.env.local
config/master.key

# Lines prefixed with ! are shell commands, run inside the new worktree
! bundle install
! pnpm install
```

Each entry is either a path to copy over from the source checkout, a `!`
prefix that runs the rest of the line as a shell command in the new
worktree, or a comment. I use it like this:

```
$ git worktree-copy ../work-queue
```

Everything after the path is passed straight through to `git worktree add`,
so any flag that works there works here too. See the
[gist][worktree-copy] for the full script.

## Shared Caches, Separate Databases

Two other gotchas, both about state that lives _alongside_ the worktree
rather than inside it.

**Node dependencies.** Copying `node_modules` across worktrees burns disk and
install time quickly. If your project is on [`pnpm`][pnpm], this is a non-issue
— packages land once in a global content-addressable store and get symlinked
into each worktree's `node_modules`, so a fresh worktree costs almost no
disk. If you're still on `npm` or `yarn`, multiplying `node_modules` across
worktrees is a reasonable excuse to switch.

**Rails + Postgres databases.** If your worktrees share a database, they'll
step on each other's schema migrations and data. I parameterize
`config/database.yml` so the database name derives from the worktree's
directory, with an environment variable escape hatch when I want to override
it:

```
<%
  database_base_name = ENV.fetch("DATABASE_BASE_NAME") do
    "myapp_#{Rails.root.basename.to_s.gsub(/\W+/, "_")}"
  end
%>

development:
  database: <%= database_base_name %>
```

Each worktree now gets its own database keyed to its directory name. The
`gsub` scrubs dashes and other non-word characters so Postgres identifiers
stay clean, and setting `DATABASE_BASE_NAME` (in `.env` or on the CLI)
overrides the auto-inferred name when I want to point two worktrees at a
shared database intentionally. SQLite doesn't need any of this — the
database file lives in the repo and gets its own copy per worktree
naturally.

## A Note on Branch Naming

Because the `work-queue` directory hosts many branches over its lifetime, the
branch names need to be self-descriptive. I prefix every branch with the
ticket ID from my tracker (for example, `TICKET-1234-fix-login`). That way
`git branch --list` and `gh pr list` both tell me what I have in flight
without me having to remember which branch was about what. It also makes the
next post in this series — where I let Claude Code drive the pipeline —
possible, because the agent can match branches back to tickets without
guessing.

## When Not to Use This

Worktrees-as-swimlanes earns its keep when:

- You regularly have more than one branch in flight.
- Your setup tax (install, migrate, configure) is non-trivial — enough that
  a blank checkout is painful.
- You switch contexts often: feature work → review → hotfix → back to
  feature.

It is overkill when the repo is small enough that a single checkout and the
occasional `git stash` is fine, or when branches are short-lived enough that
they merge before the overhead of setting up a worktree pays off.

## What's Next

This setup is worth the effort on its own if you've ever lost ten minutes to
rebuilding a checkout after a context switch. But the real reason I landed on
it is that it lets me pipeline work with an AI agent — one swimlane executing
on the next ticket while I'm reviewing the previous one in another. That's
the subject of the next post.

[claude-code]: https://claude.com/claude-code
[pnpm]: https://pnpm.io/
[worktree-copy]: https://gist.github.com/reagent/a33e0c098f8f2229ce6a3b265f876a4d
