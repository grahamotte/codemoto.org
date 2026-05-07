---
name: debug
description: Lists the main debugging tools for this project in usual likelihood of usefulness: code, `mise deploy:query`, NozSig MCP, `mise deploy:cmd`, and `mise deploy:status`. Use when debugging, investigating, triaging, or diagnosing behavior.
---

# Debug

Use these tools to debug the user's problem. Debug only. Do not try to fix anything or change code unless prompted to. Ask clarifying questions to aid debugging if needed.

Tools, in usual likelihood of usefulness:

1. The code: inspect implementation, tests, configuration, and recent changes in the current repository. Rails schema lives in `backend/db/schema.rb`; observability service name is set from `OTEL_SERVICE_NAME`.
2. `mise deploy:query`: run read-only SQL against the production database. Use Rails models and schema to understand table shape and domain context when writing queries. Requires an active, reachable deployment host.
3. NozSig MCP: query SigNoz observability data across many services. Use service filters, usually the current `service.name`; list services first if the exact name is unclear.
4. `mise deploy:cmd`: run a command on the deployment host. Useful for logs and host/service inspection; requires an active, reachable deployment host.
5. `mise deploy:status`: show deployment status, service state, host resources, and current deployed commit. Also confirms whether a deployment host is active before using SSH-backed tools.
