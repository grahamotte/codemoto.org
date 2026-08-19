# Kanban

This directory is the repository's local work board. Each card is a Markdown file that lives in exactly one column directory.

Only work with the Kanban board when the user asks to create or manage cards, or asks for work on an existing card. Changes do not require a card by default. Never create a card unless the user explicitly instructs you to do so.

## Columns

1. `1 - Problems to Solve/` contains work that has not started.
2. `2 - In Progress/` contains work an agent is actively implementing.
3. `3 - In Review/` contains completed work awaiting user review.
4. `4 - Done/` contains work the user has approved and the agent has committed.

## Cards

Name each card `<CODE> - <Title>.md`, where `<CODE>` is a four-letter uppercase code and `<Title>` is a concise description of the problem. For example:

```text
SRAT - Review attachments are missing from App Store Connect submissions.md
```

Cards describe problems to solve, not solutions to implement. Describe the current situation, affected users, evidence, impact, and desired outcome. Never prescribe a solution, implementation, architecture, interface, or technical approach in a card.

Use this basic template for each card:

```markdown
# <title>

## user value

As a <user type>, I want to <do thing>, so that <value>.

## Problem description

<freeform description of problem>

## Status, notes, context, etc (optional)

<agent to edit as desired or needed>
```

Keep useful problem and review context in the card so another agent chat can continue the work without turning the card into an implementation plan.

Refer to a card by its code, title, or filename. Preserve its filename while moving it between columns.

## Workflow

1. When the user instructs you to create a card, create it in `1 - Problems to Solve/`.
2. When the user asks an agent to work on a card, the agent moves it to `2 - In Progress/` before changing the implementation.
3. The card remains in `2 - In Progress/` across agent chats until an agent is satisfied that the work is complete and verified.
4. The agent moves completed work to `3 - In Review/` and asks the user to review it. The implementation and card move remain uncommitted while review is pending.
5. If the user reports an issue or requests a change, the agent moves the card back to `2 - In Progress/`, updates the work, verifies it, and returns the card to `3 - In Review/`.
6. When the user explicitly approves the work, the agent moves the card to `4 - Done/` and commits the completed work and card move together.

## Other

There will always be exceptions to the rules, so use your best judgement and consider the guidance the user has given to you.
