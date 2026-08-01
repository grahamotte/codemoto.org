require_relative "../test_helper"

class InstanceCreatePatchTest < Minitest::Test
  def test_needed
    Req.expects(:call).returns(droplets: [])
    assert InstanceCreatePatch.needed?

    Instance.clear
    Req.expects(:call).returns(droplets: [ active_instance ])
    refute InstanceCreatePatch.needed?
  end

  def test_apply
    Req.expects(:call).with(has_entry(:url, "https://api.digitalocean.com/v2/images"))
      .returns(images: [ { slug: "ubuntu-x64", id: 1 } ])
    Req.expects(:call).with(has_entry(:url, "https://api.digitalocean.com/v2/account/keys"))
      .returns(ssh_keys: [ { fingerprint: "fingerprint", id: 2 } ])
    Req.expects(:call).with(has_entries(method: :post, url: "https://api.digitalocean.com/v2/droplets"))
      .returns(id: 3)
    Req.expects(:call).with(has_entries(method: :get, url: "https://api.digitalocean.com/v2/droplets"))
      .returns(droplets: [ active_instance ])
    Cmd.expects(:ssh).with("echo !ass!tits!", user: "root").returns("!ass!tits!")
    commands = []
    Cmd.stubs(:local).with { |command, *| commands << command; true }

    InstanceCreatePatch.apply

    assert_includes commands, "ssh-keygen -R 1.2.3.4"
    assert_includes commands, "ssh-keygen -R example.com"
    assert_includes commands, "ssh-keyscan -H 1.2.3.4 >> ~/.ssh/known_hosts"
    assert_includes commands, "ssh-keyscan -H example.com >> ~/.ssh/known_hosts"
  end

  def test_instance_ready_handles_ssh_failure
    Req.expects(:call).returns(droplets: [ active_instance ])
    Cmd.expects(:ssh).raises("failure")

    refute InstanceCreatePatch.send(:instance_ready?)
  end

  private

  def active_instance
    {
      name: "example.com",
      id: 3,
      status: "active",
      networks: { v4: [ { type: "public", ip_address: "1.2.3.4" } ] },
    }
  end
end
