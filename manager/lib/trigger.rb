class Trigger
  READY = "ready for agent"
  WORKING = "agent working"
  APPROVED = "approved"

  class << self
    def call
      Plane.work_items.each do |item|
        case Plane.column(item)
        when READY
          Plane.move(item, WORKING)
          begin
            Agent.start(work_prompt(item))
          rescue StandardError
            Plane.move(item, READY)
            raise
          end
          puts "started working on #{Plane.identifier(item)}"
        when APPROVED
          Agent.start(merge_prompt(item))
          puts "merging #{Plane.identifier(item)}"
        end
      end
    end

    private

    def work_prompt(item)
      <<~PROMPT
        Do this Plane card: #{Plane.url(item)}

        1. Open a worktree.
        2. Hard set to the current origin main.
        3. Read the card and all comments.
        4. Implement the work.
        5. If you finish:
           - Commit
           - Open a GitHub PR with `gh pr create` using `GITHUB_TOKEN`
           - Link the PR to the card
           - Move the card to waiting for review
        6. If the card is blocked or the change is not possible:
           - Comment on the card explaining why
           - Move the card to groom
      PROMPT
    end

    def merge_prompt(item)
      <<~PROMPT
        This Plane card is approved: #{Plane.url(item)}

        1. Rebase the GitHub PR on the card. Resolve merge conflicts.
        2. Merge the PR with `gh pr merge` using `GITHUB_TOKEN`.
        3. Remove any worktrees created for this card.
        4. Move the card to done.
      PROMPT
    end
  end
end
