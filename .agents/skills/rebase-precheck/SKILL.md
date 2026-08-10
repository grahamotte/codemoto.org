---
name: rebase-precheck
description: Check whether a repository can be rebased. Use when invoked by the rebase or rebase-all skill, or when the user explicitly invokes `$rebase-precheck` or asks to use the rebase-precheck skill by name.
---

# Workflow

Check and report every item. Do not stop after the first failure. Fail the precheck if any item fails.

- The repository is a Git worktree with a valid `HEAD`.
- It has no uncommitted changes.
- It has no Git operation in progress.
- `mise test` passes.
