require_relative "../test_helper"

class MetricsPatchTest < Minitest::Test
  def test_needed
    Cmd.expects(:ssh).returns("LoadState=loaded\nActiveState=inactive\nFreezerState=dead\n")
    assert MetricsPatch.needed?

    Cmd.expects(:ssh).returns("LoadState=loaded\nActiveState=active\nFreezerState=running\n")
    refute MetricsPatch.needed?
  end

  def test_apply
    Cmd.expects(:ssh).with("curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash")

    MetricsPatch.apply
  end
end
