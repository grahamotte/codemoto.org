# Rules

**THESE ARE VERY IMPORTANT RULES FOR THIS PROJECT. REMEMBER AND OBEY THEM OR SOMEONE WILL GET FIRED AND WONT BE ABLE TO FEED THEIR CHILDREN ANYMORE.**

## General

- This repository is a batteries-included web app setup with a Rails API, React frontend, deployment tooling, shared Ruby gems, and reusable patterns baked in. Keep its structure simple, robust, and thoroughly tested.
- Every time you're done making a change, run the WHOLE test suite, not just the ones relevant to the change you made. You can run the whole test suite easily by running `mise test`
- DO NOT try to run the app or the dev server or anything like that.

## Testing

- Never run network requests, system commands, or application sleeps in tests. Stub those boundaries every time.
- Every business-logic file must have one corresponding unit test file. Source and test files are 1:1.
- Test each business-logic unit thoroughly. Configuration, generated files, framework shells, and other files without business logic do not need tests.
- Do not write integration tests.
- Do not stub other units in a unit test. Only stub network requests, system commands, and sleeps so the real local collaborators and full local surface are exercised together.
- After every change, run the whole suite with `mise test`.

## Overall Rules

When the user says "remember this" or similar, do this:

- Review the current chat conversation in its entirety.
- Review the introspection document located at <project_root>/.cursor/rules/introspection.mdc
- Update this file with any significant learnings from the conversation.
- Remember, this file is for general structural notes about the system, getting too specific will muddle the usefulness of the document.
- Also, remember, these notes are for you in the future, so orient them as such.

## Ruby

- Do not add comments to the code
- Run specific test with `mise exec -- bundle exec ruby -I test <file>`
- Do not use .empty?, .nil?, if obj, etc - use .blank? or .present? always
- NEVER use `sleep`, you are doing something wrong if you sleep
- Always test your code unless explicitly told not to
- Always use double quotes for strings
- Always add a trailing comma in multiline lists of arguments

## Typescript

- Whenever something is null it's null | undefined, in zod terms it's nullish, NEVER type or check just null or just undefined, always both.
- Do not add comments to the code
- Test TypeScript business logic with its corresponding unit test file
- Use `pnpm`, not npm
- Use `mise tsc` to typecheck -- DO NOT TYPE CHECK ANY OTHER WAY!
- Use lodash when possible
- Use ShadCN components, ask for them to be installed if they dont exist
- Use tailwind for styles
