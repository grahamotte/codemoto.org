require_relative "../../test_helper"

class AppsSimulatorTest < Minitest::Test
  def test_builds_and_launches_simulator
    commands = []
    Cmd.stubs(:local).with do |command|
      commands << command
      true
    end.returns("iPhone 17 Pro (00000000-0000-0000-0000-000000000000) (Shutdown)")

    Apps::Simulator.call("iphone")

    assert commands.any? { |command| command.include?("xcodebuild") }
    assert commands.any? { |command| command.include?("simctl install") }
    assert commands.any? { |command| command.include?("simctl launch") }
  end

  def test_rejects_unknown_simulator
    error = assert_raises(RuntimeError) { Apps::Simulator.call("watch") }

    assert_includes error.message, "Unknown simulator"
  end

  def test_builds_and_launches_macos_app
    config_path = File.join(Apps.root, "config.json")
    config = JSON.parse(File.read(config_path))
    config.fetch("targets").fetch("apple")["macos"] = {
      archiveDestination: "generic/platform=macOS",
      bundleIdentifier: "org.example.app",
      platform: "MAC_OS",
      project: File.join(Apps.root, "apple", "App.xcodeproj"),
      scheme: "App-macOS",
      simulatorDestination: "platform=macOS",
      simulatorProduct: "Debug/App-macOS.app",
      simulators: { macos: "Mac" },
    }
    File.write(config_path, JSON.generate(config))
    Apps.reset
    Apps.root = File.join(@deploy_test_dir, "apps")
    Apps.tmp_root = File.join(@deploy_test_dir, "artifacts")
    commands = []
    Cmd.stubs(:local).with { |command| commands << command; true }.returns("")

    Apps::Simulator.call("macos")

    assert commands.any? { |command| command.include?("platform\\=macOS") }
    assert commands.any? { |command| command.include?("open") && command.include?("App-macOS.app") }
    refute commands.any? { |command| command.include?("simctl") }
  end
end
