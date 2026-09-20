# AGENTS.md

## Code Moto

This repo is based on Code Moto. Code Moto is a basis/template repository that provides tools and patterns for downstream repositories. From a downstream repository, the basis repository is typically available at `../codemoto.org`. If the current repository is named `codemoto.org`, changes affect the Code Moto framework itself.

Repositories based on Code Moto may omit components or add their own. Backport broadly useful tools and changes to `codemoto.org` when practical.

The "Repo Specific" section below contains rules specific to this repo only.

## Project Rules

1. Do not introduce bugs or regressions.
2. Before writing code, find analogous code in the repository and follow its established patterns.
3. Do not add comments to code. Preserve existing comments unless they are incorrect or obsolete.
4. Lint, type-check, and test code changes using the tasks defined in the root `mise.toml`.
5. Use root `mise` tasks instead of invoking underlying tools directly when an applicable task exists.
6. Do not create a canvas or visualization unless the user specifically requests one.

## Ruby

- Use `.blank?` and `.present?` for presence checks instead of `.empty?`, `.nil?`, or truthiness checks.
- Do not use `sleep`; use an event- or state-based approach instead.
- Add trailing commas to multiline argument lists and collections.

## TypeScript

- Treat nullable values as both `null` and `undefined`; use `nullish()` in Zod schemas and check for both states.
- Use `pnpm`, not `npm`.
- Use `mise tsc` to type-check.
- Prefer Lodash utilities over custom equivalents when Lodash is already available.
- Use shadcn/ui components.
- Use Tailwind CSS for styling.

## Testing

- Never run network requests, system commands, or application sleeps in tests. Stub those boundaries every time.
- Do not stub other units in a unit test. Only stub network requests, system commands, and sleeps so the real local collaborators and full local surface are exercised together.
- Every business-logic file must have one corresponding unit test file. Source and test files are 1:1.
- Test each business-logic unit thoroughly. Configuration, generated files, framework shells, and other files without business logic do not need tests.
- After every code change, run the whole suite with `mise test`.
- Do not write integration tests.

## Plane

Work items live in Plane. Use the Plane MCP tools. Never guess a state id.

The manager in `manager/` polls Plane and starts agents so cards move without a human opening each chat. GitHub is the git host; `origin` is GitHub. Codeberg is gone.

Columns, in order: `backlog`, `groom`, `ready for agent`, `agent working`, `waiting for review`, `approved`, `done`, `cancelled`.

- `backlog` / `groom`: not ready for an agent. If work is blocked, comment why and move the card to `groom`.
- `ready for agent`: the manager moves the card to `agent working` and starts a work agent.
- `agent working`: an agent is implementing the card in a git worktree from origin main/master.
- `waiting for review`: the work is in a GitHub PR. A human reviews it.
- `approved`: the manager starts a merge agent that rebases the PR, merges it, removes the card's worktrees, and moves the card to `done`.
- `done` / `cancelled`: terminal.

- Read a card: `workitem retrieve_by_identifier` with the identifier in the URL (e.g. `MOTO-1`). Then `workitem_comment list` with that `project` and `id`.
- Comment: `workitem_comment create` with `project_id`, `workitem_id`, and `comment_html`.
- Move a card: `state list` for the project, pick the state whose `name` matches the column case-insensitively, then `workitem update` with that state's id.
- Link a PR: `workitem_link create` with `project_id`, `workitem_id`, and the PR `url`.

## Manager

`manager/` is a Ruby watcher. `mise manager:watch` polls Plane every 60 seconds. `mise manager:trigger` runs one pass.

On `ready for agent` it starts a work session. That agent must:

1. Open a git worktree.
2. Hard set it to the current origin main/master.
3. Read the card and all comments.
4. Implement the work.
5. If it finishes: commit, open a GitHub PR with `gh pr create` using `GITHUB_TOKEN`, link the PR to the card, and move the card to `waiting for review`.
6. If the card is blocked: comment why and move the card to `groom`.

On `approved` it starts a merge session. That agent must rebase the GitHub PR, merge it with `gh pr merge` using `GITHUB_TOKEN`, remove worktrees created for the card, and move the card to `done`.

There is no commit skill. Commit when the task asks you to.

## Merge

Downstream repositories pull Code Moto with `$merge` (one repo) or `$merge-all` (from `codemoto.org`, every sibling). Follow `.agents/skills/merge/SKILL.md`. After merging, clean obsolete Codeberg remotes as that skill describes.

## GitHub

Open pull requests on GitHub with `gh`, using `GITHUB_TOKEN` from the environment.

- Push the branch, then `gh pr create`.
- Merge with `gh pr merge`.

## File Structure

- `.agents/skills/` - Project-specific agent skills.
- `.env.*` - Environment configuration and secrets. Do not expose secret values.
- `apps/` - Mobile apps for iOS and Android.
- `apps/config.json` - Mobile app release configuration.
- `assets/` - Shared images and media.
- `backend/` - Ruby on Rails API server.
- `deploy/` - Backend, frontend, and mobile app deployment tooling.
- `docs/` - Project documentation in Markdown.
- `frontend/` - React website.
- `frontend/subdomains.json` - Website subdomain configuration.
- `gems/` - Shared Ruby gems.
- `manager/` - Plane work-item polling and agent triggers.
- `scripts/` - General-purpose scripts.
- `mise.toml` - Project tooling and task definitions.

## Repo Specific

None.
