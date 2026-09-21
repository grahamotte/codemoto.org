# MOTO-28: Update mise manager:sync statuses and tags

- Identifier: MOTO-28
- ID: af772f3a-3f25-4ff1-8e4b-bdd8b28660ee
- URL: https://linear.app/gotte/issue/MOTO-28/update-mise-managersync-statuses-and-tags
- State: Completed
- Priority: No priority
- Estimate: none
- Due date: none
- Assignee: linear@graham.lol
- Creator: linear@graham.lol
- Parent: none
- Children: none
- Labels: working
- Created: 2026-09-21T04:59:00.260Z
- Updated: 2026-09-21T05:16:03.642Z
- Completed: 2026-09-21T05:15:29.615Z

## Description

can we update the colors for the statues to what is in the screenshot? (these are default linear colors)

can we also add these labels/tags with the colors show as well.

the idea is that when running mise manager:sync we get a defautl set of statuses and tags with clear order and color

![Screenshot 2026-09-20 at 9.59.44 PM.png](https://uploads.linear.app/abd0504f-0da2-4d94-87b3-24c0d24d46e0/b1a03b45-863c-42c1-aa3b-9ee935f3edc0/a1dc7c61-3e01-4bd5-946d-6cb53a0c1987)

![Screenshot 2026-09-20 at 9.56.37 PM.png](https://uploads.linear.app/abd0504f-0da2-4d94-87b3-24c0d24d46e0/fdbb835c-613c-4885-b839-c5f8d0fc1cad/0b9d52ab-7346-4b00-9b46-ab20f5a284df)

### Screenshot 1 — Screenshot 2026-09-20 at 9.59.44 PM.png

Linear team settings **Issue statuses & automations** for **Code Moto**. Header: `Linear / Gotte / Code Moto / Team settings`, tab **Workflow**.

Left nav: General, Issue statuses & automations (selected), Labels, Templates, Issue types, Recurring issues, SLAs, Notifications, Members, GitHub, GitLab, Asks.

Main heading **Issue statuses & automations**. Subtitle: "How should issues in Code Moto be organized and automated?"

**Triage** is on. **Backlog** is on.

Statuses and default Linear colors, in order:

- **Backlog** — Backlog (orange)
- **Unstarted** — Planned (gray)
- **Started** — Ready (cyan), Working (yellow), Review (orange), Approved (green)
- **Completed** — Completed (purple)
- **Canceled** — Canceled (gray), Duplicate (gray)

Each row has a drag handle, status name, colored pill, and a three-dot menu.

### Screenshot 2 — Screenshot 2026-09-20 at 9.56.37 PM.png

Linear team settings **Labels** for **Code Moto**. Header: `Linear / Gotte / Code Moto / Team settings`, tab **Labels**.

Left nav: General, Issue statuses & automations, Labels (selected), then the rest of team settings.

Main heading **Labels**. Subtitle: "Labels can be grouped by namespace". Search field, **New group**, **New label**.

Label list (group **Labels**, 6 labels):

- working (yellow)
- variant: low (green)
- variant: medium (green)
- variant: high (green)
- variant: xhigh (green)
- model: xai/grok-4.6 (cyan)

Each row has a drag handle, colored dot, label name, and a three-dot menu.

## Comments

### linear@graham.lol — 2026-09-21T05:10:14.063Z

- ID: b5bdfe5d-602f-4174-8eab-c075321bd155
- Updated: 2026-09-21T05:10:14.049Z

`mise manager:sync` now applies the screenshot status colors (Ready cyan, Working yellow, Review orange, Approved green) and creates the default `working`, `variant: …`, and `model: xai/grok-4.6` tags. Existing tags get recolored when they drift.

PR: https://github.com/grahamotte/codemoto.org/pull/44

## Attachments

- [Update Linear sync status colors and default tags](https://github.com/grahamotte/codemoto.org/pull/44)
