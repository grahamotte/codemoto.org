require_relative "../../test_helper"

class AppsBuildPatchTest < Minitest::Test
  def test_builds_missing_archives
    commands = []
    Cmd.stubs(:local).with { |command| commands << command; true }.returns("")

    assert Apps::BuildPatch.needed?
    Apps::BuildPatch.apply

    command = commands.fetch(0)
    assert_includes command, "xcodebuild archive"
    assert_includes command, "MARKETING_VERSION\\=1.2.3"
    assert_includes command, "CURRENT_PROJECT_VERSION\\=1.2.3"
    assert_includes command, "PRODUCT_BUNDLE_IDENTIFIER\\=org.example.app"
    assert_includes command, "generic/platform\\=iOS"
    Apps.authentication_arguments.each { |argument| assert_includes command, Shellwords.escape(argument) }
  end

  def test_skips_existing_archives
    FileUtils.mkdir_p(Apps.archive_path(Apps.targets.fetch(0)))

    refute Apps::BuildPatch.needed?
  end
end
