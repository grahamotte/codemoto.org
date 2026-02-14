---
name: rebase
description: Run `mise rebase`, prompt the user if there are issues, and run `mise test` after a successful rebase.
---

# Rebase Command

Use this skill when the user asks to run the rebase workflow.

## Workflow

1. Run `mise rebase`.
2. If `mise rebase` reports issues (for example conflicts or other git errors), stop and prompt the user with the error and what decision is needed.
3. After we have successfully rebased, run `mise test`.
4. Report results clearly and include next action needed from the user if something failed.
