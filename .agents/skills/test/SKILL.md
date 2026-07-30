---
name: test
description: Run `mise test` and fix failures by updating tests only. If code changes seem necessary, ask the user first. You may fix rubocop or lint/format errors without asking.
disable-model-invocation: true
---

# Test Command

Use this skill when the user asks to run the test command workflow.

## Workflow

1. Run `mise test`.
2. Fix failures by changing tests only.
3. If you believe app code should be changed instead of tests (for clear logic, setup, or code issues), stop and ask the user before modifying code.
4. You may fix rubocop and other lint/format issues without asking.
