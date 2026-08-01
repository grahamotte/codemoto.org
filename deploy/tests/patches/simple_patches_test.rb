require_relative "../test_helper"

class MetricsPatchTest < Minitest::Test
  def test_needed
    Instance.stubs(:service_running?).with("do-agent").returns(false)
    assert MetricsPatch.needed?

    Instance.stubs(:service_running?).with("do-agent").returns(true)
    refute MetricsPatch.needed?
  end

  def test_apply
    Cmd.expects(:ssh).with("curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash")

    MetricsPatch.apply
  end
end

class DnsPatchTest < Minitest::Test
  def test_needed
    Cloudflare.stubs(:zone_id).returns(nil)
    assert DnsPatch.needed?

    Cloudflare.stubs(:zone_id).returns("zone")
    Cloudflare.stubs(:current_records_are_desired?).returns(true)
    refute DnsPatch.needed?
  end

  def test_apply_replaces_records_and_creates_missing_zone
    Cloudflare.stubs(:zone_id).returns(nil)
    Cloudflare.expects(:create_zone)
    Cloudflare.stubs(:current_dns_records).returns([ { id: "old" } ])
    Cloudflare.stubs(:desired_dns_records).returns([ { name: "new" } ])
    Cloudflare.expects(:delete_dns_record).with("old")
    Cloudflare.expects(:create_dns_record).with({ name: "new" })

    DnsPatch.apply
  end
end

class InstanceDestroyPatchTest < Minitest::Test
  def test_always_removes_dns_and_instance
    Cloudflare.stubs(:current_dns_records).returns([ { id: "one" }, { id: "two" } ])
    Cloudflare.expects(:delete_dns_record).with("one")
    Cloudflare.expects(:delete_dns_record).with("two")
    Instance.expects(:destroy)

    InstanceDestroyPatch.always
  end
end

class SwapPatchTest < Minitest::Test
  def test_skips_existing_swap
    Cmd.expects(:ssh).with("sudo swapon --show").returns("/swapfile")

    SwapPatch.always
  end

  def test_creates_swap_and_fstab_entry
    Cmd.expects(:ssh).with("sudo swapon --show").twice.returns("", "/swapfile")
    Cmd.expects(:ssh).with("sudo swapoff -a")
    Cmd.expects(:ssh).with("sudo rm -f /swapfile")
    Cmd.expects(:ssh).with("sudo fallocate -l 5G /swapfile")
    Cmd.expects(:ssh).with("sudo chmod 600 /swapfile")
    Cmd.expects(:ssh).with("sudo mkswap /swapfile")
    Cmd.expects(:ssh).with("sudo swapon /swapfile")
    Cmd.expects(:ssh).with("cat /etc/fstab").returns("")
    Cmd.expects(:ssh).with("echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab")

    SwapPatch.always
  end
end
