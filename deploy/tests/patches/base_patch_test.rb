require_relative "../test_helper"

class BasePatchTest < Minitest::Test
  def test_call_runs_always_and_applies_when_needed
    patch = Class.new(BasePatch)
    patch.stubs(:name).returns("ExamplePatch")
    patch.stubs(:puts)
    patch.expects(:always)
    patch.expects(:needed?).returns(true)
    patch.expects(:apply)

    patch.call
  end

  def test_call_skips_apply_when_not_needed
    patch = Class.new(BasePatch)
    patch.stubs(:name).returns("ExamplePatch")
    patch.stubs(:puts)
    patch.expects(:always)
    patch.expects(:needed?).returns(false)
    patch.expects(:apply).never

    patch.call
  end
end
