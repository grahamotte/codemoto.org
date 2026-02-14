---
name: quick-deploy
description: Run `mise quick` and report whether it succeeded or failed, including key output and next action if it fails.
---

# Quick Deploy Command

Use this skill when the user asks for a quick deploy workflow.

## Workflow

1. Run `mise quick`.
2. If the command fails, report the failure clearly with the key error output and what action is needed from the user.
3. If the command succeeds, report success and include a concise summary of the result.
