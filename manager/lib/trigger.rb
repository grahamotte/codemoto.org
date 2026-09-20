class Trigger
  READY = "ready"
  WORKING = "working"
  APPROVED = "approved"

  class << self
    def call
      Linear.issues.each do |item|
        case Linear.column(item)
        when READY
          Linear.move(item, WORKING)
          begin
            Agent.start(work_prompt(item), directory: Worktree.open(item))
          rescue StandardError
            Linear.move(item, READY)
            raise
          end
          puts "started working on #{Linear.identifier(item)}"
        when APPROVED
          Agent.start(merge_prompt(item), directory: Worktree.directory(item))
          puts "merging #{Linear.identifier(item)}"
        end
      end
    end

    private

    def work_prompt(item)
      <<~PROMPT
        Do this Linear issue: #{Linear.url(item)}

        This may be a new card or a kickback with corrections in later comments. There may already be a worktree, commits, and a PR.

        1. This session is already in the card worktree. Env files and schema.rb were copied from the main checkout.
        2. Rebase onto the current origin main. Do not hard-reset; keep existing commits.
        3. Read the card and all comments.
        4. Implement the work. You may edit existing commits or add new ones.
        5. If you finish:
           - Commit
           - Open a GitHub PR with `gh pr create` using `GITHUB_TOKEN`
           - Link the PR to the card
           - Comment on the card describing what you did
           - Move the card to review
        6. If the card is blocked or the change is not possible:
           - Comment on the card explaining why
           - Move the card to planned
      PROMPT
    end

    def merge_prompt(item)
      <<~PROMPT
        This Linear issue is approved: #{Linear.url(item)}

        1. Rebase the GitHub PR on the card. Resolve merge conflicts.
        2. Merge the PR with `gh pr merge` using `GITHUB_TOKEN`.
        3. Remove any worktrees created for this card.
        4. Move the card to completed.
      PROMPT
    end
  end
end
