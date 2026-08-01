require_relative "../test_helper"

class InstanceCreatePatchTest < Minitest::Test
  def test_needed_when_instance_is_not_running
    Instance.stubs(:running?).returns(false)
    assert InstanceCreatePatch.needed?

    Instance.stubs(:running?).returns(true)
    refute InstanceCreatePatch.needed?
  end

  def test_apply_creates_instance_and_updates_host_keys
    Cache.expects(:clear)
    Instance.expects(:clear)
    Instance.expects(:create)
    InstanceCreatePatch.stubs(:instance_ready?).returns(false, true)
    InstanceCreatePatch.stubs(:sleep)
    Instance.stubs(:ip).returns("1.2.3.4")
    Constants.stubs(:domain).returns("example.com")
    Cmd.expects(:local).with("ssh-keygen -R 1.2.3.4")
    Cmd.expects(:local).with("ssh-keygen -R example.com")
    Cmd.expects(:local).with("ssh-keyscan -H 1.2.3.4 >> ~/.ssh/known_hosts")
    Cmd.expects(:local).with("ssh-keyscan -H example.com >> ~/.ssh/known_hosts")

    InstanceCreatePatch.apply
  end

  def test_instance_ready
    Instance.expects(:clear)
    Instance.stubs(:running?).returns(true)
    Cmd.expects(:ssh).with("echo !ass!tits!", user: "root").returns("!ass!tits!")

    assert InstanceCreatePatch.send(:instance_ready?)
  end

  def test_instance_not_ready_on_ssh_failure
    Instance.stubs(:clear)
    Instance.stubs(:running?).returns(true)
    Cmd.expects(:ssh).raises("failure")

    refute InstanceCreatePatch.send(:instance_ready?)
  end
end
