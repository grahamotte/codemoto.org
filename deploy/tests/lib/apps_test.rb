require_relative "../test_helper"

class AppsTest < Minitest::Test
  def test_loads_configuration
    assert_equal "1.2.3", Apps.version
    assert_equal "1.2.3", Apps.build
    assert_equal :ios, Apps.targets.fetch(0).fetch(:name)
    assert_equal File.join(@deploy_test_dir, "artifacts", "1.2.3", "ios.xcarchive"), Apps.archive_path(Apps.targets.fetch(0))
  end

  def test_builds_authentication_arguments
    arguments = Apps.authentication_arguments

    assert_includes arguments, ENV.fetch("APPLE_KEY_ID")
    assert_includes arguments, ENV.fetch("APPLE_ISSUER_ID")
    assert File.file?(Apps.private_key_path)
    assert_equal 0600, File.stat(Apps.private_key_path).mode & 0777
  end

  def test_reports_invalid_json
    File.write(File.join(Apps.root, "config.json"), "{")
    Apps.reset
    Apps.root = File.join(@deploy_test_dir, "apps")

    error = assert_raises(RuntimeError) { Apps.config }

    assert_includes error.message, "Invalid JSON"
  end
end
