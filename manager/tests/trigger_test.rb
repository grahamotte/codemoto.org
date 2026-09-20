require_relative "test_helper"

class TriggerTest < Minitest::Test
  def test_moves_ready_cards_and_starts_work_agent
    calls = stub_manager(
      items: [
        { id: "item-1", identifier: "MOTO-1", url: "https://linear.app/gotte/issue/MOTO-1", state: { id: "s-ready", name: "Ready" } },
        { id: "item-2", identifier: "MOTO-2", url: "https://linear.app/gotte/issue/MOTO-2", state: { id: "s-planned", name: "Planned" } },
      ],
    )

    output, = capture_io { Trigger.call }

    assert_equal "started working on MOTO-1\n", output
    assert_equal(
      { id: "item-1", input: { stateId: "s-working" } },
      calls.find { |call| graphql?(call, "mutation IssueUpdate") }.dig(:payload, :variables),
    )
    prompt = prompt_for(calls, "MOTO-1")
    assert_includes prompt, "Do this Linear issue: https://linear.app/gotte/issue/MOTO-1"
    assert_includes prompt, "This may be a new card or a kickback with corrections in later comments."
    assert_includes prompt, "There may already be a worktree, commits, and a PR."
    assert_includes prompt, "Open a worktree."
    assert_includes prompt, "Rebase onto the current origin main. Do not hard-reset; keep existing commits."
    assert_includes prompt, "You may edit existing commits or add new ones."
    assert_includes prompt, "Open a GitHub PR with `gh pr create` using `GITHUB_TOKEN`"
    assert_includes prompt, "Comment on the card describing what you did"
    assert_includes prompt, "Move the card to review"
    assert_includes prompt, "Move the card to planned"
    refute_includes prompt, "Hard set to the current origin main."
    refute calls.any? { |call| call[:prompt].to_s.include?("MOTO-2") }
  end

  def test_starts_merge_agent_for_approved_cards
    calls = stub_manager(
      items: [
        { id: "item-3", identifier: "MOTO-3", url: "https://linear.app/gotte/issue/MOTO-3", state: { id: "s-approved", name: "Approved" } },
      ],
    )

    output, = capture_io { Trigger.call }

    assert_equal "merging MOTO-3\n", output
    refute calls.any? { |call| graphql?(call, "mutation IssueUpdate") }
    prompt = prompt_for(calls, "MOTO-3")
    assert_includes prompt, "This Linear issue is approved: https://linear.app/gotte/issue/MOTO-3"
    assert_includes prompt, "Rebase the GitHub PR on the card."
    assert_includes prompt, "Merge the PR with `gh pr merge` using `GITHUB_TOKEN`."
    assert_includes prompt, "Move the card to completed."
  end

  def test_moves_ready_card_back_when_agent_fails
    calls = stub_manager(
      items: [
        { id: "item-1", identifier: "MOTO-1", url: "https://linear.app/gotte/issue/MOTO-1", state: { id: "s-ready", name: "Ready" } },
      ],
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:url].to_s.end_with?("/api/openchamber/sessions")

      true
    end.raises("agent failed")

    output, = capture_io do
      assert_raises(RuntimeError) { Trigger.call }
    end

    assert_equal "", output
    states = calls.select { |call| graphql?(call, "mutation IssueUpdate") }.map { |call| call.dig(:payload, :variables, :input, :stateId) }
    assert_equal [ "s-working", "s-ready" ], states
  end

  def test_handles_ready_and_approved_together
    calls = stub_manager(
      items: [
        { id: "item-1", identifier: "MOTO-1", url: "https://linear.app/gotte/issue/MOTO-1", state: { id: "s-ready", name: "Ready" } },
        { id: "item-3", identifier: "MOTO-3", url: "https://linear.app/gotte/issue/MOTO-3", state: { id: "s-approved", name: "Approved" } },
      ],
    )

    output, = capture_io { Trigger.call }

    assert_equal "started working on MOTO-1\nmerging MOTO-3\n", output
    assert_equal 1, calls.count { |call| graphql?(call, "mutation IssueUpdate") }
    assert_includes prompt_for(calls, "MOTO-1"), "Open a worktree."
    assert_includes prompt_for(calls, "MOTO-1"), "Rebase onto the current origin main. Do not hard-reset; keep existing commits."
    assert_includes prompt_for(calls, "MOTO-3"), "Rebase the GitHub PR on the card."
  end

  def test_prints_nothing_when_nothing_is_triggered
    stub_manager(
      items: [
        { id: "item-2", identifier: "MOTO-2", url: "https://linear.app/gotte/issue/MOTO-2", state: { id: "s-planned", name: "Planned" } },
      ],
    )

    assert_output("") { Trigger.call }
  end

  private

  def graphql?(opts, fragment)
    opts[:url] == Linear::HOST && opts.dig(:payload, :query).to_s.include?(fragment)
  end

  def stub_manager(items:)
    calls = []
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:url].to_s.end_with?("/api/openchamber/sessions")

      calls << { prompt: opts.dig(:payload, :prompt) }
      true
    end.returns({ sessionId: "ses-1" })
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless graphql?(opts, "query Workspace")

      calls << opts
      true
    end.returns(
      {
        data: {
          organization: { urlKey: "gotte" },
          teams: { nodes: [ { id: "team-1", key: "MOTO" } ] },
        },
      },
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless graphql?(opts, "query States")

      calls << opts
      true
    end.returns(
      {
        data: {
          team: {
            states: {
              nodes: [
                { id: "s-ready", name: "Ready", type: "started" },
                { id: "s-working", name: "Working", type: "started" },
                { id: "s-planned", name: "Planned", type: "unstarted" },
                { id: "s-approved", name: "Approved", type: "started" },
              ],
            },
          },
        },
      },
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless graphql?(opts, "query Issues")

      calls << opts
      true
    end.returns(
      {
        data: {
          team: {
            issues: {
              nodes: items,
              pageInfo: { hasNextPage: false, endCursor: nil },
            },
          },
        },
      },
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless graphql?(opts, "mutation IssueUpdate")

      calls << opts
      true
    end.returns({ data: { issueUpdate: { success: true } } })
    calls
  end

  def prompt_for(calls, identifier)
    calls
      .map { |call| call[:prompt] }
      .compact
      .find { |text| text.include?(identifier) }
  end
end
