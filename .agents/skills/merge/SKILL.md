---
name: merge
description: Merge the latest Code Moto into a downstream repository without rewriting its history. Use only when the user explicitly invokes `$merge` or asks to use the merge skill by name.
---

# Workflow

1. Before starting the merge, run the `merge-precheck` skill. If the precheck fails, abort the merge.
2. Record `git rev-parse HEAD` and echo it to the user as the merge recovery point.
3. Run `mise merge`.
4. If it stops with conflicts, inspect the output and repository state. Resolve every conflict, stage the resolutions, and run `GIT_EDITOR=true git merge --continue`. Repeat until the merge finishes.
5. Preserve the intent of both Code Moto and downstream changes. Inspect surrounding code, history, and tests when a resolution is not obvious.
6. Ask the user only when there is genuine ambiguity with materially different valid outcomes, or progress requires information or authority only they can provide. Explain the exact decision needed; do not stop merely because a conflict or failure occurred.
7. Run `mise test` after the merge succeeds. Fix merge-related failures and rerun the whole suite until it passes.
8. Clean git remotes as below.
9. Report the completed merge, conflict resolutions, merge commit, remote cleanup, and test results.

# Git remotes

Code Moto no longer uses Codeberg. GitHub is `origin`. After a successful merge, inspect `git remote -v` and leave the downstream repo with:

- `origin` → this repository on GitHub (`git@github.com:<owner>/<repo>.git`)
- `upstream` → `git@github.com:grahamotte/codemoto.org.git`
- `deployment` unchanged, if present

Then:

1. If `origin` is Codeberg or missing, point it at this repository's GitHub URL. That URL is often already on a `github` or `origin_backup` remote.
2. Remove `codeberg`.
3. Remove `github` and `origin_backup` once `origin` is GitHub.
4. If `upstream` still points at Codeberg, run `git remote set-url upstream git@github.com:grahamotte/codemoto.org.git`. `mise merge` usually already did this.

Do not rename remotes in a way that leaves Codeberg as `origin`.
