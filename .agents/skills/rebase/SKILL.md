---
name: rebase
description: Run `mise rebase`, resolve conflicts and other actionable failures, and run `mise test`. Use only when the user explicitly invokes `$rebase` or asks to use the rebase skill by name.
---

# Rebase Command

## Workflow

1. Run `mise rebase`.
2. If it stops, inspect the output and repository state. Resolve conflicts or other actionable failures, stage the resolutions, and continue the rebase. Repeat until the rebase finishes.
3. Preserve the intent of both upstream and downstream changes. Inspect surrounding code, history, and tests when the resolution is not obvious.
4. Ask the user only when there is genuine ambiguity with materially different valid outcomes, or progress requires information or authority only they can provide. Explain the exact decision needed; do not stop merely because a conflict or failure occurred.
5. Run `mise test` after the rebase succeeds. Fix rebase-related failures and rerun the whole suite until it passes.
6. Report the completed rebase, conflict resolutions, and test result.
