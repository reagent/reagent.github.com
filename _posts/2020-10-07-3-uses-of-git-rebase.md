---
title: 3 Uses of `git rebase` for Your Daily Workflow
---

[Rebasing][1] is a way of rewriting your local history by applying commits to your 
working tree in a different order from how they were originally made.

There are 3 flavors that I find useful in my daily work:

1. `git rebase <branch-name>`
1. `git rebase -i <commit>`
1. `git rebase --onto <new-base> <old-base>`


### Using `git rebase <branch-name>`

I use this to get my local branch history up-to-date with the mainline 
development branch. It allows for a linear history on my branch and optionally a
linear history on the main branch.

For example, here I have branched off `master` to `feature` and the histories 
have diverged:

```
a--b--c--d   master
    \
     e--f--g feature
```

I now want to apply my changes from `feature` to `master`, but I want to include 
the current history of `master` into `feature` so that my main branch can have a
 linear history. I can use `git rebase` to make this happen:

```
$ git checkout master
$ git pull # get my local master in sync with remote
$ git checkout feature
```

At this point, I'm ready to modify my branch to have a new "base" -- looking at 
the previous history, the first commit on `feature` (commit `e`) has a "base" 
(or parent commit) of `b`. Instead, I want to change my history to be based off 
of a different parent (`d` or `master` in this case):

```
$ git rebase master
```

This version of `rebase` will get `feature` up-to-date with the current `master` 
and then _re-apply_ all the commits from `feature` on top of this new "base". If
 there are any conflicts, I'll have a chance to correct them and continue the 
 process.

Once completed, my history will look like this:

```
a--b--c--d   master
          \
           e'--f'--g' feature
```

Each of these _new_ commits performs the same changes, but the "prime" (`'`) 
indicator designates that these have different SHAs and, due to our desired 
rebase operation, different parents.

Now, I can choose to merge this with master and maintain a linear history:

```
$ git checkout master
$ git merge feature --ff-only # Don't create a merge commit
```

Now my history looks like this:

```
a--b--c--d--e'--f'--g'  master
```

### Using `git rebase -i <commit>`

Before rebasing `master`, I'll typically use the `--interactive` variant to 
clean up my commit history by providing better comments and grouping related 
changes together into a single commit.

Let's say that I branched off of `master` and made a few changes on my branch 
that I'm about ready to merge back in:

```
  * update .gitignore
  |
  * moar config
  |
* * wip
| |
* * config
|/
*
```

It's useful to just be able to add commits as backstops as I'm figuring out how 
to actually get something working, but I don't want these unhelpful comments 
showing up in the history. I can use an interactive rebase to reorder, change, 
and even delete the commits that I've made.

Now that I have a handle on what changes I actually need, I've decided that I 
want to:

1. Combine the 2 commits that changed the config file
1. Modify the commit message for the config file changes
1. Modify the commit message for our WIP commmit
1. Remove the commit that changes the `.gitignore` file

If I invoke `git rebase` with `-i`, it will drop me into my default editor:

```
$ git rebase -i HEAD~4 # can also take a commit SHA
```

My editor (in this case, vim) will be invoked and display the relevant commit 
history:

```
pick 0cb4a62 config
pick 1f7c8d7 wip
pick 2151280 moar config
pick bcc7808 update .gitignore

# Rebase 0b4f673..bcc7808 onto 0b4f673 (4 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

By default these are all marked as `pick` -- exiting the editor without 
modifications won't change the commit history. If I move the commits around and 
label each like the following:

```
reword 0cb4a62 config
fixup 2151280 moar config
reword 1f7c8d7 wip
```

Exiting the editor will start the rebase operation and drop us into the editor 
to update, or "reword" the commit messages we want to change. Once completed, 
we'll be left with a history that might look like this:

```
* * Add helper script to decrypt secrets in dev
| |
* * Add secrets to main config file
|/
*
```

Now we're ready to rebase and merge into our `master` branch.

### Using `git rebase --onto <new-base> <old-base>`

At times, I may make a feature branch that, while I'm waiting to merge it, I 
would like to start another feature that requires changes made on that feature 
branch:

```
a--b--c--d     master
    \
     e--f      feature-1
         \
          g--h feature-2
```

After merging my first feature to `master`, my new feature branch `feature-2` 
has diverged:

```
a--b--c--d--e'--f' master
    \
     e--f--g--h   feature-2
```

We can see that, although `e` and `f` are the same as what are on `master`, they
 have different SHAs, so if we merge these, we'll be in for a bad time. The 
 answer is to apply our commits from `feature-2` on top of commit `f'` while 
 dropping the duplicate commits on the floor. `git rebase --onto` to the rescue:

```
$ git rebase --onto f' f
```

This will apply our new commits from `feature-2` (commits `g` and `h`) on top of
 `f'` -- we now end up like this:

```
a--b--c--d--e'--f' master
                 \
                  g--h   feature-2
```

Now I can do any other needed work to get `feature-2` ready to merge with 
`master`.

[1]: https://git-scm.com/book/en/v2/Git-Branching-Rebasing