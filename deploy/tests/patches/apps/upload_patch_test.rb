require_relative "../../test_helper"

class AppsUploadPatchTest < Minitest::Test
  def test_uploads_archives_once
    target = Apps.targets.fetch(0)
    FileUtils.mkdir_p(Apps.archive_path(target))
    commands = []
    Cmd.stubs(:local).with { |command| commands << command; true }.returns("")

    Apps::UploadPatch.apply
    Apps::UploadPatch.apply

    assert_equal 1, commands.length
    assert_includes commands.fetch(0), "xcodebuild -exportArchive"
    Apps.authentication_arguments.each { |argument| assert_includes commands.fetch(0), Shellwords.escape(argument) }
    refute Apps::UploadPatch.needed?
  end

  def test_requires_archive
    assert_raises(RuntimeError) { Apps::UploadPatch.apply }
  end
end
