---
name: merge-worktrees
description: Clean up orphaned worktree branches that weren't merged by /end (crashed sessions, etc). Use when the user says "merge worktrees", "clean up worktrees", or invokes "/merge-worktrees".
---

# /merge-worktrees - Clean up orphaned worktree branches

Normally `/end` merges the worktree into main and cleans up. This skill handles orphaned branches from crashed or interrupted sessions that never ran `/end`.

## Step 1: Find orphaned branches

Run `git worktree list` and check for branches under `.claude/worktrees/` paths.

Also check for leftover branches without worktree directories:
```
git branch --list 'claude-worktree-*'
```

For each branch with commits ahead of main, show:
- Branch name
- Commit count ahead of main (`git rev-list main..<branch> --count`)
- Last commit date and message (`git log -1 --format="%ci %s" <branch>`)

If no orphaned branches exist, report that and stop.

## Step 2: Confirm merge

Present the list to the user and ask which branches to merge (default: all).

## Step 3: Merge branches

For each confirmed branch:

1. Ensure you're on main: `git checkout main`
2. `git merge <branch> --no-ff -m "Merge worktree: <branch summary>"`

If merge conflicts occur:
- Stop and show the conflicts
- Let the user resolve before continuing

## Step 4: Clean up

For each successfully merged branch:
1. Delete the local branch: `git branch -d <branch>`
2. Remove the worktree directory if it still exists: `git worktree remove <path>`
3. Run `git worktree prune` to clean up stale entries

## Step 5: Push

Push to remote: `git push`

## Step 6: Report

Present:
- **Branches merged** - list with commit summaries
- **Conflicts encountered** - any that required resolution
- **Current main state** - latest commit message
- **Remaining branches** - any that were skipped or failed
