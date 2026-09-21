# MOTO-26: Be able to override model and variant

- Identifier: MOTO-26
- ID: 5897de15-44fe-4001-a6eb-64cfa9e8b196
- URL: https://linear.app/gotte/issue/MOTO-26/be-able-to-override-model-and-variant
- State: Completed
- Priority: No priority
- Estimate: none
- Due date: none
- Assignee: linear@graham.lol
- Creator: linear@graham.lol
- Parent: none
- Children: none
- Labels: variant: medium, model: xai/grok-4.6, working
- Created: 2026-09-21T04:39:51.052Z
- Updated: 2026-09-21T04:57:47.425Z
- Completed: 2026-09-21T04:56:44.774Z

## Description

I would like to be able to specify the model and the variant in the card. here are example I may label the card with:

variant: high

model: xai/grok-4.6

I have also added example tags for this format. we need to parse these tags so we know to spin up the agent correctly.

if no tags are specified, then we should use the default of course

## Comments

### linear@graham.lol — 2026-09-21T04:48:22.961Z

- ID: 7193187f-321c-4d42-b8af-fbdca2f8f873
- Updated: 2026-09-21T04:48:22.940Z

The manager now reads Linear labels in the `model: …` and `variant: …` format and passes them to OpenChamber when it starts an agent. Cards without those tags keep the `AGENT_MODEL` / `AGENT_VARIANT` defaults.

PR: https://github.com/grahamotte/codemoto.org/pull/40

## Attachments

- [Parse Linear model and variant tags when starting agents](https://github.com/grahamotte/codemoto.org/pull/40)
