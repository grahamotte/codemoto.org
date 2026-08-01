require_relative "../test_helper"

class InstanceTest < Minitest::Test
  def test_service_running
    Cmd.expects(:ssh)
      .with("systemctl show --no-page --property=LoadState,ActiveState,FreezerState api.service")
      .returns("LoadState=loaded\nActiveState=active\nFreezerState=running\n")

    assert Instance.service_running?("api")
  end

  def test_service_not_running
    Cmd.expects(:ssh).returns("LoadState=loaded\nActiveState=inactive\nFreezerState=dead\n")

    refute Instance.service_running?("api")
  end
end
