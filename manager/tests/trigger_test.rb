require_relative "test_helper"

class TriggerTest < Minitest::Test
  def test_moves_ready_cards_and_starts_work_agent
    calls = stub_manager(
      items: [
        { id: "item-1", sequence_id: 1, state: { id: "s-ready", name: "ready for agent" } },
        { id: "item-2", sequence_id: 2, state: { id: "s-groom", name: "groom" } },
      ],
    )

    output, = capture_io { Trigger.call }

    assert_equal "started working on MOTO-1\n", output
    assert_equal(
      { state: "s-working" },
      calls.find { |call| call[:method] == :patch }.fetch(:payload),
    )
    prompt = prompt_for(calls, "MOTO-1")
    assert_includes prompt, "Do this Plane card: https://app.plane.so/otte/browse/MOTO-1/"
    assert_includes prompt, "This may be a new card or a kickback with corrections in later comments."
    assert_includes prompt, "There may already be a worktree, commits, and a PR."
    assert_includes prompt, "Open a worktree."
    assert_includes prompt, "Rebase onto the current origin main. Do not hard-reset; keep existing commits."
    assert_includes prompt, "You may edit existing commits or add new ones."
    assert_includes prompt, "Open a GitHub PR with `gh pr create` using `GITHUB_TOKEN`"
    assert_includes prompt, "Comment on the card describing what you did"
    assert_includes prompt, "Move the card to waiting for review"
    assert_includes prompt, "Move the card to groom"
    refute_includes prompt, "Hard set to the current origin main."
    refute calls.any? { |call| call[:prompt].to_s.include?("MOTO-2") }
  end

  def test_starts_merge_agent_for_approved_cards
    calls = stub_manager(
      items: [
        { id: "item-3", sequence_id: 3, state: { id: "s-approved", name: "approved" } },
      ],
    )

    output, = capture_io { Trigger.call }

    assert_equal "merging MOTO-3\n", output
    refute calls.any? { |call| call[:method] == :patch }
    prompt = prompt_for(calls, "MOTO-3")
    assert_includes prompt, "This Plane card is approved: https://app.plane.so/otte/browse/MOTO-3/"
    assert_includes prompt, "Rebase the GitHub PR on the card."
    assert_includes prompt, "Merge the PR with `gh pr merge` using `GITHUB_TOKEN`."
    assert_includes prompt, "Move the card to done."
  end

  def test_moves_ready_card_back_when_agent_fails
    calls = stub_manager(
      items: [
        { id: "item-1", sequence_id: 1, state: { id: "s-ready", name: "ready for agent" } },
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
    states = calls.select { |call| call[:method] == :patch }.map { |call| call.dig(:payload, :state) }
    assert_equal [ "s-working", "s-ready" ], states
  end

  def test_handles_ready_and_approved_together
    calls = stub_manager(
      items: [
        { id: "item-1", sequence_id: 1, state: { id: "s-ready", name: "ready for agent" } },
        { id: "item-3", sequence_id: 3, state: { id: "s-approved", name: "approved" } },
      ],
    )

    output, = capture_io { Trigger.call }

    assert_equal "started working on MOTO-1\nmerging MOTO-3\n", output
    assert_equal 1, calls.count { |call| call[:method] == :patch }
    assert_includes prompt_for(calls, "MOTO-1"), "Open a worktree."
    assert_includes prompt_for(calls, "MOTO-1"), "Rebase onto the current origin main. Do not hard-reset; keep existing commits."
    assert_includes prompt_for(calls, "MOTO-3"), "Rebase the GitHub PR on the card."
  end

  def test_prints_nothing_when_nothing_is_triggered
    stub_manager(
      items: [
        { id: "item-2", sequence_id: 2, state: { id: "s-groom", name: "groom" } },
      ],
    )

    assert_output("") { Trigger.call }
  end

  private

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
      next false unless opts[:url].end_with?("/projects/")

      calls << opts
      true
    end.returns(
      [
        { id: "proj-1", identifier: "MOTO" },
      ],
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:url].end_with?("/states/")

      calls << opts
      true
    end.returns(
      {
        results: [
          { id: "s-ready", name: "ready for agent" },
          { id: "s-working", name: "agent working" },
          { id: "s-groom", name: "groom" },
          { id: "s-approved", name: "approved" },
        ],
      },
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:url].end_with?("/work-items/") && opts[:method] != :patch

      calls << opts
      true
    end.returns({ results: items })
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:method] == :patch

      calls << opts
      true
    end.returns({})
    calls
  end

  def prompt_for(calls, identifier)
    calls
      .map { |call| call[:prompt] }
      .compact
      .find { |text| text.include?(identifier) }
  end
end
