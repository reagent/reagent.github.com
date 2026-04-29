---
title: Pipelining a Claude Code Workflow with Swimlane Worktrees
---

Running a coding agent changes how a day flows: the agent works in bursts,
and you wait. If everything runs through a single checkout, that waiting is
dead time — you can't review the last PR while the agent is writing the next
one, because they'd be stepping on the same files.

Swimlane worktrees solve this. In the [previous post][post-1], I laid out
the idea of treating worktrees as persistent roles rather than per-feature
containers. Here's how I layer an agent-driven workflow on top of that
structure so the agent and I can work in parallel instead of in sequence.

## The Setup, Briefly

The short version of the [previous post][post-1]: I keep four worktrees per
repo, each with a job.

- `development` — the main checkout, where I branch off.
- `work-queue` — the agent's active workspace; branches rotate in and out
  per ticket.
- `review` — where draft-PR branches get checked out for post-PR comment
  iteration.
- `experiments` — spikes and longer-running exploration.

Each worktree has its own VS Code window with [Claude Code][claude-code]
running in the integrated terminal. The setup gets me two things:
filesystem isolation (the agent's current work doesn't collide with the
review I'm doing) and a dedicated agent session per role (so the context
in each session matches the worktree's purpose).

## A Ticket, Start to Finish

A single ticket passes through four phases. Here's what each looks like in
practice.

### 1. Kickoff

I'm in the `work-queue` window. I have a custom slash command called
`/work-queue-manager` (backed by Atlassian's Remote MCP server) that surfaces
the current release's tickets grouped by status — To Do, In Progress, In
Review, In Test — with size and priority annotations.

When I'm ready to start something, I ask the agent one of three things:

- `what's next?` — the agent picks a small, high-priority ticket from To
  Do.
- `let's work on TICKET-1234` — when I know exactly which one.
- `was there a ticket about the login redirect thing?` — when I remember
  the work but not the ID.

The agent reads the ticket, creates a branch off `development` with a
ticket-prefixed name (`TICKET-1234-fix-login`), and starts implementing.

### 2. Pre-review

When the agent is done with its first pass, the work sits on a branch in
`work-queue` — but no PR exists yet. Before one does, I read the diff.

This is the step that gets skipped in most AI workflow writeups, and it's
the single most valuable discipline in the whole flow. An agent that ships
its own code straight to a PR will get merged garbage past any reviewer who
trusts the author. A pre-review catches the issues that are obvious once
you look — wrong edge cases, missed cleanup, code that doesn't match the
house style — before they become GitHub comments someone else has to
write.

I read the diff, then either:

- instruct the agent to fix specific issues (_"this function should
  short-circuit if the user is already logged in"_), or
- make the edits myself when they're small and mechanical (a rename, a
  typo, a missing newline).

Only after I'm satisfied does the PR open.

### 3. Draft PR

The agent opens the PR itself, using the `gh` CLI:

```
$ gh pr create --draft --title '...' --body '...'
```

It writes the title and body from the commit context — what was
implemented, what changed, what's worth flagging to the reviewer. Because
I've already done the pre-review pass, the PR is something I'd be
comfortable assigning a real reviewer to, even while it's in draft state.

### 4. Iterate in `review`

Once the PR is open, I leave `work-queue` and switch to the `review`
window, where I check out the PR branch:

```
$ git fetch origin
$ git checkout TICKET-1234-fix-login
```

`review` is now the active swimlane for this ticket. When review comments
come in — from me, from a teammate, or from an automated check — I ask the
agent to read and address them via `gh`:

```
$ gh api repos/:owner/:repo/pulls/123/comments
```

The agent walks through threaded comments and inline code comments one at
a time and pushes fixup commits. I supervise and course-correct when its
interpretation of a comment is off.

## Running the Pipeline

The whole point of splitting into `work-queue` and `review` is that they
can be active at the same time. While I'm in the `review` window iterating
on comments for ticket N, I can be kicking off ticket N+1 in the
`work-queue` window — a fresh `/work-queue-manager` interaction, a new
branch, the agent starts implementing.

Two Claude Code sessions. Two worktrees. Two ticket states. The agent is
writing code for N+1 while I'm steering N through review. Neither one is
waiting for the other.

The overlap isn't always clean — ticket N+1's implementation sometimes has
questions that block the agent until I respond, and review comments on N
sometimes require focused attention that pulls me out of the work-queue
loop. But the baseline is: when the agent has something to do, it's doing
it; when I have something to do, I'm doing it. The swimlanes keep those
activities from colliding.

## `/clear` Is a Judgment Call

Most AI workflow posts that mention `/clear` recommend running it
religiously at every task boundary. I don't.

`/clear` drops the current session's accumulated context — what the agent
has built up about what you've been working on. That's valuable when
you're switching to something unrelated, because carrying the old context
forward just pollutes the next task with noise that looks relevant but
isn't.

It's wasteful when the next ticket is a continuation. If I just finished a
ticket that rewrote a service's authentication flow, and the next ticket
adds two-factor support to that same flow, clearing would force the
session to rebuild context it already has. Keeping the session alive is
strictly cheaper.

Rule of thumb: clear when the next ticket touches different code,
different concepts, or different stakeholders. Keep context when it's an
extension of what just landed.

## About `/work-queue-manager`

I've referenced this custom slash command a few times. It's worth a quick
sketch of what it does, because the design informs the rhythm.

The skill wraps Atlassian's Remote MCP server with a specific view: the
current release's tickets, grouped by status lane (To Do / In Progress /
In Review / In Test), annotated with size and priority. Calling it with no
arguments prints that full view — I can see at a glance where everything
stands.

Calling it with a prompt lets me talk through ticket selection naturally,
as above: `what's next?`, `let's work on TICKET-1234`, `was there a ticket
about X?`. The skill also knows how to create the branch, start the
implementation, and (later) open the draft PR.

It's specific to my Jira setup, but the shape generalizes — if your team
uses Linear or GitHub Issues, the same pattern works with the relevant MCP
server in place of Atlassian's.

## Where It Breaks

A few honest failure modes I've hit:

**Pre-review misses something subtle.** I scan the diff, it looks fine,
the PR opens, and then a teammate catches a logic error I glossed over.
Pre-review is a filter, not a guarantee — the discipline reduces the rate
of sloppy PRs, it doesn't eliminate them.

**`/clear` wipes context I needed.** I'll clear, then realize the next
ticket actually does depend on the previous one. The fix is to re-prime
the agent with a quick summary of what's relevant; the cost is seconds,
not minutes — but it's a reminder that the "judgment call" is a real call,
not an idle instinct.

**The agent over-runs the ticket scope.** Given a small ticket, the agent
sometimes decides to "also fix" things that are adjacent but out of scope.
I catch these in pre-review and either revert the scope creep or split it
into its own ticket. A sharper prompt at kickoff helps, but doesn't
eliminate the pattern.

## Worth It?

The setup is a handful of worktrees, a custom slash command, and a
discipline around pre-review and selective `/clear`. The payoff is that my
time and the agent's time stop competing for the same checkout, and ticket
throughput roughly doubles for the kind of work where the agent can run
ahead of me.

It isn't free. The pre-review pass is real work; so is keeping the
`/work-queue-manager` skill accurate as Jira conventions shift. If your
team works in a single repo with short-lived branches and a light review
culture, the overhead won't pay off. If you're juggling a steady stream of
tickets, more than one in flight at a time, against a nontrivial codebase
— this is what actually works.

[claude-code]: https://claude.com/claude-code
[post-1]: /articles/git-worktrees-as-swimlanes
