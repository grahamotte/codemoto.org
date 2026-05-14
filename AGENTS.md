# Rules

**THESE ARE VERY IMPORTANT RULES FOR THIS PROJECT. REMEMBER AND OBEY THEM OR SOMEONE WILL GET FIRED AND WONT BE ABLE TO FEED THEIR CHILDREN ANYMORE.**

## General

- Every time you're done making a change, run the WHOLE test suite, not just the ones relevant to the change you made. You can run the whole test suite easily by running `mise test`
- DO NOT try to run the app or the dev server or anything like that.

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
- For slow code, you can use `mise profile <script.rb or test.rb>` to understand why (this sometimes times out, so try a couple times before giving up)

## Typescript

- Whenever something is null it's null | undefined, in zod terms it's nullish, NEVER type or check just null or just undefined, always both.
- Do not add comments to the code
- Do not test typescript code
- Use `pnpm`, not npm
- Use `mise tsc` to typecheck -- DO NOT TYPE CHECK ANY OTHER WAY!
- Use lodash when possible
- Use ShadCN components, ask for them to be installed if they dont exist
- Use tailwind for styles
