require_relative "../test_helper"

class InstanceTest < Minitest::Test
  def setup
    Instance.clear
  end

  def test_image_id_selects_latest_ubuntu_x64_image
    Instance.stubs(:req).returns(images: [
      { slug: "ubuntu-24-x64", id: 1 },
      { slug: "ubuntu-26-arm64", id: 2 },
      { slug: "ubuntu-26-x64", id: 3 },
    ])

    assert_equal 3, Instance.image_id
  end

  def test_ssh_key_id_uses_existing_key
    Constants.stubs(:ssh_key_fingerprint).returns("fingerprint")
    Instance.expects(:req).with(:get, "account/keys", quiet: true).returns(
      ssh_keys: [ { fingerprint: "fingerprint", id: 4 } ],
    )

    assert_equal 4, Instance.ssh_key_id
  end

  def test_ssh_key_id_creates_missing_key
    Constants.stubs(:ssh_key_fingerprint).returns("missing")
    Constants.stubs(:domain).returns("example.com")
    Constants.stubs(:ssh_key_pub).returns("public-key")
    Instance.expects(:req).with(:get, "account/keys", quiet: true).returns(ssh_keys: [])
    Instance.expects(:req)
      .with(:post, "account/keys", payload: { name: "example.com", public_key: "public-key" })
      .returns(ssh_key: { id: 5 })

    assert_equal 5, Instance.ssh_key_id
  end

  def test_show_ip_and_running_state
    Constants.stubs(:domain).returns("example.com")
    Instance.stubs(:req).returns(droplets: [
      { name: "other.com" },
      {
        name: "example.com",
        id: 6,
        status: "active",
        networks: { v4: [ { type: "private", ip_address: "10.0.0.1" }, { type: "public", ip_address: "1.2.3.4" } ] },
      },
    ])

    assert_equal 6, Instance.instance_id
    assert_equal "1.2.3.4", Instance.ip
    assert Instance.running?
  end

  def test_create
    Constants.stubs(:domain).returns("example.com")
    Constants.stubs(:instance_region).returns("region")
    Constants.stubs(:instance_size).returns("size")
    Instance.stubs(:image_id).returns(1)
    Instance.stubs(:ssh_key_id).returns(2)
    Instance.expects(:req).with(
      :post,
      "droplets",
      payload: { name: "example.com", region: "region", image: 1, size: "size", ssh_keys: [ 2 ] },
      quiet: true,
    ).returns(id: 3)

    assert_equal({ id: 3 }, Instance.create)
  end

  def test_destroy
    Instance.stubs(:instance_id).returns(6)
    Instance.expects(:req).with(:delete, "droplets/6")

    Instance.destroy
  end

  def test_destroy_without_instance
    Instance.stubs(:instance_id).returns(nil)

    assert_raises(RuntimeError) { Instance.destroy }
  end

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

  def test_stop_service_ignores_failure
    Cmd.expects(:ssh).raises("failure")

    assert_nil Instance.stop_service("api")
  end

  def test_start_service
    Cmd.expects(:ssh).with("sudo systemctl daemon-reload")
    Cmd.expects(:ssh).with("sudo systemctl start api.service")
    Cmd.expects(:ssh).with("sudo systemctl enable api.service")
    Instance.stubs(:sleep)
    Instance.stubs(:service_running?).with("api").returns(true)

    Instance.start_service("api")
  end

  def test_start_service_failure
    Cmd.stubs(:ssh)
    Instance.stubs(:sleep)
    Instance.stubs(:service_running?).returns(false)

    assert_raises(RuntimeError) { Instance.start_service("api") }
  end

  def test_write_service_skips_unchanged_definition
    Cache.stubs(:unchanged?).returns(true)

    assert_nil Instance.write_service("api", "definition")
  end

  def test_write_service
    Cache.stubs(:unchanged?).returns(false)
    Cmd.expects(:ssh_write).with("/etc/systemd/system/api.service", "definition", sudo: true)
    Cmd.expects(:ssh).with("sudo systemctl daemon-reload")
    Cmd.expects(:ssh).with("sudo systemctl enable api.service")
    Cache.expects(:set).with("/etc/systemd/system/api.service", "definition")

    Instance.write_service("api", "definition")
  end

  def test_restart_service
    Instance.expects(:stop_service).with("api")
    Instance.expects(:start_service).with("api")

    Instance.restart_service("api")
  end

  def test_package_state
    Cmd.expects(:ssh).with("which ffmpeg").returns("/usr/bin/ffmpeg")
    assert Instance.installed?("ffmpeg")

    Cmd.expects(:ssh).with("which missing").raises("missing")
    refute Instance.installed?("missing")
  end

  def test_install_package
    Instance.stubs(:installed?).with("convert").returns(false)
    Cmd.expects(:ssh).with("sudo apt-get install -y imagemagick")

    Instance.install_package("imagemagick", bin: "convert")
  end

  def test_skips_installed_package
    Instance.stubs(:installed?).returns(true)

    assert_nil Instance.install_package("ffmpeg")
  end
end
