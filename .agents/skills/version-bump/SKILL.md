---
name: version-bump
description: Bump the app version by reviewing changes since the last version bump, choosing the smallest sensible semantic version change, and synchronizing the release config and Xcode project versions. Use when the user invokes $version-bump or asks to bump the app version.
---

# Version Bump

Do the analysis yourself. Do not add or run a repo helper script.

## Workflow

1. Find the most recent commit whose subject is exactly `Version`.
   - If none exists, find the commit that introduced the current `version` in `apps/config.json`.
2. Review subsequent commits and inspect their diffs when their subjects are insufficient.
3. Choose the smallest sensible semantic version bump:
   - `major` for intentional breaking changes.
   - `minor` for new user-visible capability.
   - `patch` for fixes, polish, refactors, and internal work.
4. Stop and ask the user to confirm a `major` bump. Do not ask for `minor` or `patch` confirmation.
5. Update every location listed below.
6. Run `mise test`.
7. If it passes, commit only the listed files with the subject `Version`.
8. Report the old version, new version, release notes, and bump reasoning.

## Version Locations

Update `apps/config.json`:

- `version`: Set to the new semantic version.
- `build`: Set to the same new semantic version.
- `whatsNew`: Replace with a concise, user-facing summary grounded in the reviewed changes. Use exactly `Bug fixes.` when nothing user-facing is notable.

Inspect the Apple targets in `apps/config.json` and resolve each configured Xcode project. In every project:

- Find every existing `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`, regardless of platform, target, or build configuration.
- Set each occurrence to the same new semantic version used in `apps/config.json`.
- Do not assume that any particular platform or configuration exists, and do not add missing settings.
- Verify that no discovered version setting retains the old value.

## Guidance

- Treat `apps/config.json` as the release source of truth and keep the Xcode project synchronized with it.
- Prefer judgment over commit-message rules and default to the smaller bump when ambiguous.
- Do not bump when there are no release-worthy changes after the boundary.
- Keep the commit subject exactly `Version` so the next bump has a clean boundary.
- Commit only `apps/config.json` and the Xcode project files changed by this workflow.
- Do not build, upload, submit, publish, or run a development server.
