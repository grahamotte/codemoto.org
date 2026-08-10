---
name: rebase
description: Rebase the repo on the latest Code Moto. Use only when the user explicitly invokes `$rebase` or asks to use the rebase skill by name.
---

# Workflow

1. Before starting the rebase, run the `rebase-precheck` skill. If the precheck fails, abort the rebase.
2. Record `git reflog -1 --format='%gd %H'` and echo it to the user as the rebase recovery point.
3. Run `mise rebase`.
4. If it stops, inspect the output and repository state. Resolve conflicts or other actionable failures, stage the resolutions, and continue the rebase. Repeat until the rebase finishes.
5. Preserve the intent of both upstream and downstream changes. Inspect surrounding code, history, and tests when the resolution is not obvious.
6. Ask the user only when there is genuine ambiguity with materially different valid outcomes, or progress requires information or authority only they can provide. Explain the exact decision needed; do not stop merely because a conflict or failure occurred.
7. Run `mise test` after the rebase succeeds. Fix rebase-related failures and rerun the whole suite until it passes.
8. Report the completed rebase, conflict resolutions, and test results.
