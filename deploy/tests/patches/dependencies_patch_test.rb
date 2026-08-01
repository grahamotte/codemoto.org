require_relative "../test_helper"

class DependenciesPatchTest < Minitest::Test
  def setup
    DependenciesPatch.instance_variable_set(:@current_versions, nil)
  end

  def test_always_configures_packages_and_mise
    Instance.expects(:install_package).with("ffmpeg")
    Instance.expects(:install_package).with("imagemagick", bin: "convert")
    Instance.stubs(:installed?).with("mise").returns(true)
    Cmd.expects(:ssh).with('mise settings add idiomatic_version_file_enable_tools "[]"')
    Cmd.expects(:ssh).with("mise settings set ruby.compile=false")

    DependenciesPatch.always
  end

  def test_always_installs_missing_mise
    Instance.stubs(:install_package)
    Instance.stubs(:installed?).with("mise").returns(false)
    Cmd.stubs(:ssh)
    Cmd.expects(:ssh).with("sudo apt install -y mise")

    DependenciesPatch.always
  end

  def test_needed_when_any_tool_version_is_missing
    DependenciesPatch.stubs(:tool_versions).returns({ "ruby" => "4.0.6", "node" => "26" })
    DependenciesPatch.expects(:version_not_installed?).with("ruby", "4.0.6").returns(false)
    DependenciesPatch.expects(:version_not_installed?).with("node", "26").returns(true)

    assert DependenciesPatch.needed?
  end

  def test_not_needed_when_all_versions_are_installed
    DependenciesPatch.stubs(:tool_versions).returns({ "ruby" => "4.0.6" })
    DependenciesPatch.stubs(:version_not_installed?).returns(false)

    refute DependenciesPatch.needed?
  end

  def test_apply
    Constants.stubs(:remote_root).returns("/app")
    Cmd.expects(:ssh).with("cd /app && mise -y trust -a")
    Cmd.expects(:ssh).with(includes("build-essential"))
    Cmd.expects(:ssh).with("mkdir -p ~/tmp")
    Cmd.expects(:ssh).with(includes("mise install --yes"), "/app")

    DependenciesPatch.apply
  end

  def test_version_installed
    DependenciesPatch.stubs(:current_versions).returns(ruby: [ { version: "4.0.6", installed: true } ])

    assert DependenciesPatch.send(:version_installed?, "ruby", "4.0.6")
    refute DependenciesPatch.send(:version_installed?, "ruby", "3.0.0")
  end

  def test_current_versions_handles_invalid_output
    Cmd.expects(:ssh).with("mise list --json").returns('{"ruby":[{"version":"4.0.6","installed":true}]}')
    assert_equal "4.0.6", DependenciesPatch.send(:current_versions).dig(:ruby, 0, :version)

    DependenciesPatch.instance_variable_set(:@current_versions, nil)
    Cmd.expects(:ssh).raises("failure")
    assert_equal({}, DependenciesPatch.send(:current_versions))
  end
end
