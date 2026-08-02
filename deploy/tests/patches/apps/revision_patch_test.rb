require_relative "../../test_helper"

class AppsRevisionPatchTest < Minitest::Test
  def test_uploads_each_signed_app_to_both_repositories_once
    target = Apps.targets.fetch(0)
    product = File.join(Apps.archive_path(target), "Products", "Applications", "App.app")
    FileUtils.mkdir_p(product)
    commands = []
    Cmd.expects(:local).twice.with do |command|
      commands << command
      File.write(Apps.revision_path(target), "signed-app") if command.include?("ditto")
      true
    end.returns("")
    Req.expects(:call).with { |request| request[:method].blank? }.twice.returns([])
    Req.expects(:call).with { |request| request[:method] == :post && request[:payload].present? }
      .twice
      .returns(id: 1, assets: [])
    Req.expects(:call).with do |request|
      request[:method] == :post && request[:url].include?("/assets") && request[:body].include?("signed-app")
    end.twice.returns({})

    Apps::RevisionPatch.apply
    Apps::RevisionPatch.apply

    assert commands.any? { |command| command.include?("codesign --verify --deep --strict") }
    assert commands.any? { |command| command.include?("ditto -c -k --keepParent") }
    refute Apps::RevisionPatch.needed?
  end

  def test_requires_archive
    assert_raises(RuntimeError) { Apps::RevisionPatch.apply }
  end
end
