require_relative "../../test_helper"

class AppsBuildPatchTest < Minitest::Test
  def test_builds_missing_archives
    commands = []
    Cmd.stubs(:local).with { |command| commands << command; true }.returns("")

    assert Apps::BuildPatch.needed?
    Apps::BuildPatch.apply

    command = commands.find { |value| value.include?("xcodebuild") }
    assert_includes command, "xcodebuild archive"
    assert_includes command, "MARKETING_VERSION\\=1.2.3"
    assert_includes command, "CURRENT_PROJECT_VERSION\\=456"
    assert_includes command, "PRODUCT_BUNDLE_IDENTIFIER\\=org.example.app"
    assert_includes command, "generic/platform\\=iOS"
    assert_includes command, "CODE_SIGNING_ALLOWED\\=NO"
  end

  def test_skips_existing_archives
    target = Apps.targets.fetch(0)
    FileUtils.mkdir_p(Apps.archive_path(target))
    Cache.set("apps/#{Apps.version}/#{target.fetch(:name)}/archive/v3", "built")

    refute Apps::BuildPatch.needed?
  end

  def test_enables_hardened_runtime_for_macos
    Apps.targets.fetch(0)[:platform] = "MAC_OS"
    command = nil
    Cmd.stubs(:local).with do |value|
      command = value if value.include?("xcodebuild")
      true
    end.returns("")

    Apps::BuildPatch.apply

    assert_includes command, Shellwords.escape("ENABLE_HARDENED_RUNTIME=YES")
  end
end
