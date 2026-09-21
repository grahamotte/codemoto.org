# MOTO-27: add mise manger:syncall

- Identifier: MOTO-27
- ID: 4d977e15-4ccb-41fa-8396-7af6d6e03f55
- URL: https://linear.app/gotte/issue/MOTO-27/add-mise-mangersyncall
- State: Completed
- Priority: No priority
- Estimate: none
- Due date: none
- Assignee: linear@graham.lol
- Creator: linear@graham.lol
- Parent: none
- Children: none
- Labels: working
- Created: 2026-09-21T04:54:33.998Z
- Updated: 2026-09-21T05:03:13.068Z
- Completed: 2026-09-21T05:02:47.742Z

## Description

in the same sense that we have a mise manager:triggerall, we should have a mise manager:syncall

## Comments

### linear@graham.lol — 2026-09-21T04:57:40.706Z

- ID: d754cfec-0ff2-43d3-87df-427bdb131b95
- Updated: 2026-09-21T04:57:40.684Z

Added `mise manager:syncall`. It scans sibling directories of the current checkout, keeps git repos whose `mise.toml` defines `manager:sync` (including this Code Moto repo), skips git worktrees, and runs `mise manager:sync` in each. PR: https://github.com/grahamotte/codemoto.org/pull/41

## Attachments

- [Add mise manager:syncall](https://github.com/grahamotte/codemoto.org/pull/41)
