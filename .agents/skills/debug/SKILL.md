---
name: debug
description: Debugging workflow for this project. Prioritizes local code inspection, then read-only production queries, then production code execution as a last resort.
---

# Debug

Debug only. Do not make changes or fix code unless prompted. Ask clarifying questions to narrow the problem.

Do not read `.env`, `.env.production`, or any `.env.*` file — the `mise` tasks already have the appropriate environment access configured.

## Local

Start here. All local tools target the development environment and cannot affect production.

- **The code**: inspect implementation, tests, configuration, and recent git history. Rails schema lives in `backend/db/schema.rb`.
- **`mise runner`**: run Ruby application code locally. Use to reproduce issues or validate behavior. Accepts a code argument.
- **`mise query`**: run read-only SQL against the local database. Only SELECT, WITH, SHOW, EXPLAIN, TABLE, and VALUES forms are allowed. Accepts a query argument.
- **`mise console`**: interactive Rails console. **Do not use — for humans.** Use `mise runner` or `mise query` instead.

## Production

Move to these only after exhausting local options. Tools are listed from safest to most dangerous.

- **`mise deploy:status`**: show deployment state, service health, host resources, and current deployed commit. Also confirms whether a deployment host is reachable.
- **`mise deploy:log`**: view application logs from the deployment host.
- **`mise query:production`**: read-only SQL against the production database. Same query restrictions as `mise query`. No destructive changes are possible.
- **`mise runner:production`**: run Ruby application code against production. **Caution: can make destructive changes to live data.** Prefer `mise runner` locally and `mise query:production` for inspection.
- **`mise deploy:cmd`**: run an arbitrary command on the deployment host. **Caution: can make destructive changes to production.** Use only when the above tools are insufficient.
- **`mise console:production`**: interactive Rails console against production. **Do not use — for humans.**

No other `deploy:*` tasks should be used. Tasks like `deploy:ssh`, `deploy:pry`, `deploy:reboot`, `deploy:backup`, `deploy:restore`, `deploy:destroy`, `deploy:htop`, `deploy:deploy`, `deploy:quick`, and `deploy:push` are deployment management tools, not debugging tools.
