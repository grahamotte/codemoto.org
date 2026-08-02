require_relative "../test_helper"

class AppsTest < Minitest::Test
  def test_loads_configuration
    assert_equal "1.2.3", Apps.version
    assert_equal "456", Apps.build
    assert_equal "Description", Apps.config.fetch(:description)
    assert_equal "Changes", Apps.config.fetch(:whatsNew)
    assert_equal :ios, Apps.targets.fetch(0).fetch(:name)
    assert_equal File.join(@deploy_test_dir, "artifacts", "1.2.3", "ios.xcarchive"), Apps.archive_path(Apps.targets.fetch(0))
    Apps.config[:name] = "Example App"
    assert_equal File.join(@deploy_test_dir, "artifacts", "1.2.3", "revisions", "Example-App-ios-1.2.3.ipa"), Apps.revision_path(Apps.targets.fetch(0))
    assert_equal "codeberg.org", Apps.revision_repositories.fetch(0).fetch(:host)
    assert_equal "github.com", Apps.revision_repositories.fetch(1).fetch(:host)
    assert_equal "app", Apps.revision_repositories.fetch(1).fetch(:name)
  end

  def test_builds_authentication_arguments
    arguments = Apps.authentication_arguments

    assert_includes arguments, ENV.fetch("APPLE_KEY_ID")
    assert_includes arguments, ENV.fetch("APPLE_ISSUER_ID")
    assert File.file?(Apps.private_key_path)
    assert_equal 0600, File.stat(Apps.private_key_path).mode & 0777
    assert_equal ENV.fetch("APPLE_KEY_SECRET_BASE64").unpack1("m0"), File.binread(Apps.private_key_path)
  end

  def test_reports_invalid_json
    File.write(File.join(Apps.root, "config.json"), "{")
    Apps.reset
    Apps.root = File.join(@deploy_test_dir, "apps")

    error = assert_raises(RuntimeError) { Apps.config }

    assert_includes error.message, "Invalid JSON"
  end
end
