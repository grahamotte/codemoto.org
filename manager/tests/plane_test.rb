require_relative "test_helper"

class PlaneTest < Minitest::Test
  def test_work_items_unwraps_results
    stub_plane(
      work_items: {
        results: [
          { id: "item-1", sequence_id: 1, state: { id: "s-ready", name: "ready for agent" } },
        ],
      },
    )

    assert_equal "item-1", Plane.work_items.first.fetch(:id)
  end

  def test_work_items_accepts_array_response
    stub_plane(
      work_items: [
        { id: "item-1", sequence_id: 1 },
      ],
    )

    assert_equal "item-1", Plane.work_items.first.fetch(:id)
  end

  def test_column_from_expanded_state
    assert_equal "ready for agent", Plane.column({ state: { id: "s-ready", name: "Ready For Agent" } })
  end

  def test_column_from_state_id
    stub_plane

    assert_equal "approved", Plane.column({ state: "s-approved" })
  end

  def test_column_blank_without_state
    assert_nil Plane.column({})
  end

  def test_move_patches_state_id
    calls = stub_plane

    Plane.move({ id: "item-1" }, "agent working")

    payload = calls.find { |call| call[:method] == :patch }
    assert_equal "https://api.plane.so/api/v1/workspaces/otte/projects/proj-1/work-items/item-1/", payload.fetch(:url)
    assert_equal({ state: "s-working" }, payload.fetch(:payload))
    assert_equal({ "X-API-Key" => "plane-token" }, payload.fetch(:headers))
  end

  def test_identifier
    assert_equal "MOTO-1", Plane.identifier({ sequence_id: 1 })
  end

  def test_url
    assert_equal "https://app.plane.so/otte/browse/MOTO-1/", Plane.url({ sequence_id: 1 })
  end

  def test_url_uses_workspace_and_project_from_env
    ENV["PLANE_WORKSPACE"] = "acme"
    ENV["PLANE_PROJECT"] = "ENG"

    assert_equal "ENG-1", Plane.identifier({ sequence_id: 1 })
    assert_equal "https://app.plane.so/acme/browse/ENG-1/", Plane.url({ sequence_id: 1 })
  ensure
    ENV["PLANE_WORKSPACE"] = "otte"
    ENV["PLANE_PROJECT"] = "MOTO"
  end

  def test_selects_project_by_identifier
    calls = stub_plane(
      projects: [
        { id: "other", identifier: "OTHER" },
        { id: "proj-1", identifier: "MOTO" },
      ],
    )

    Plane.move({ id: "item-1" }, "agent working")

    assert_includes calls.find { |call| call[:method] == :patch }.fetch(:url), "/projects/proj-1/"
  end

  private

  def stub_plane(projects: nil, work_items: nil)
    calls = []
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:url].end_with?("/projects/")

      calls << opts
      true
    end.returns(
      projects || [
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
          { id: "s-ready", name: "Ready For Agent" },
          { id: "s-working", name: "Agent Working" },
          { id: "s-approved", name: "Approved" },
        ],
      },
    )
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:url].end_with?("/work-items/") && opts[:method] != :patch

      calls << opts
      true
    end.returns(work_items)
    Req.stubs(:call).with do |*args, **kwargs|
      opts = req_opts(args, kwargs)
      next false unless opts[:method] == :patch

      calls << opts
      true
    end.returns({})
    calls
  end
end
