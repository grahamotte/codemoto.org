require_relative "../../test_helper"

class AppsValidationPatchTest < Minitest::Test
  def test_validates_configuration
    Cmd.expects(:local).with("xcodebuild -version").returns("Xcode")

    Apps::ValidationPatch.apply
  end

  def test_rejects_missing_credentials
    value = ENV.delete("APPLE_KEY_ID")
    Cmd.expects(:local).with("xcodebuild -version").returns("Xcode")

    error = assert_raises(RuntimeError) { Apps::ValidationPatch.apply }

    assert_equal "Missing APPLE_KEY_ID", error.message
  ensure
    ENV["APPLE_KEY_ID"] = value
  end

  def test_rejects_mismatched_version
    File.write(
      File.join(Apps.root, "versions", "1.2.3.json"),
      JSON.generate(
        description: "Description",
        keywords: "app",
        version: "2.0.0",
        whatsNew: "Changes",
      ),
    )
    Apps.instance_variable_set(:@release, nil)
    Cmd.expects(:local).with("xcodebuild -version").returns("Xcode")

    assert_raises(RuntimeError) { Apps::ValidationPatch.apply }
  end
end
