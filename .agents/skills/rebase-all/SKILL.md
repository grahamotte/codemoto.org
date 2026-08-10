---
name: rebase-all
description: Rebase every sibling repository based on Code Moto, one at a time. Use only when the user explicitly invokes `$rebase-all` or asks to use the rebase-all skill by name.
---

# Workflow

1. Require the current directory to be the root of the `codemoto.org` repository. Fail otherwise.
2. Discover the immediate child directories of the parent directory that contain `.agents/skills/rebase/SKILL.md`. Exclude `codemoto.org` itself and sort the repositories by path.
3. Before starting any rebase, run the `rebase-precheck` skill for each discovered repository. Assign each repository to a subagent working from that repository's root. The prechecks may run in parallel, but wait for all of them and abort the rebase-all without rebasing any repository if a precheck fails.
4. After all preconditions pass, record `git reflog -1 --format='%gd %H'` for every discovered repository and echo each repository and recovery point to the user. Do not start any rebase unless every recovery point succeeds.
5. Rebase each discovered repository serially. Read and follow that repository's `.agents/skills/rebase/SKILL.md` as the authoritative rebase instructions. Finish one repository before starting the next, never work on repositories in parallel, and carry relevant learnings forward to subsequent rebases.
6. Report the result for every discovered repository. If a rebase cannot be completed, fail the rebase-all and identify the repository and blocker.
