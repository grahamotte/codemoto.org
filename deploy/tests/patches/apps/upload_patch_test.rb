require_relative "../../test_helper"

class AppsUploadPatchTest < Minitest::Test
  def test_uploads_archives_once
    target = Apps.targets.fetch(0)
    FileUtils.mkdir_p(Apps.archive_path(target))
    commands = []
    Cmd.stubs(:local).with { |command| commands << command; true }.returns("Apple Distribution")

    Apps::UploadPatch.apply
    Apps::UploadPatch.apply

    command = commands.find { |value| value.include?("xcodebuild") }
    assert_includes command, "xcodebuild -exportArchive"
    assert commands.any? { |value| value.include?("security import") }
    Apps.authentication_arguments.each { |argument| assert_includes command, Shellwords.escape(argument) }
    refute Apps::UploadPatch.needed?
  end

  def test_requires_archive
    assert_raises(RuntimeError) { Apps::UploadPatch.apply }
  end
end
