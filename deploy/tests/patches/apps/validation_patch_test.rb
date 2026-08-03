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

  def test_rejects_missing_metadata
    Apps.config[:description] = ""
    Cmd.expects(:local).with("xcodebuild -version").returns("Xcode")

    error = assert_raises(RuntimeError) { Apps::ValidationPatch.apply }

    assert_equal "Missing description in app configuration", error.message
  end

  def test_requires_demo_credentials_when_sign_in_is_required
    Apps.config[:demoAccountName] = ""
    Cmd.expects(:local).with("xcodebuild -version").returns("Xcode")

    error = assert_raises(RuntimeError) { Apps::ValidationPatch.apply }

    assert_equal "Missing demoAccountName in app configuration", error.message
  end
end
