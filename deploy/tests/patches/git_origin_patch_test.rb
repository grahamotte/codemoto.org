require_relative "../test_helper"

class GitOriginPatchTest < Minitest::Test
  def test_skips_blank_repositories
    GitOriginPatch.always
  end

  def test_pushes_configured_repository
    ENV["ORIGIN_REPO"] = "git@example.com:repo.git"
    Cmd.expects(:local).with(includes("git remote remove origin")).raises("missing")
    Cmd.expects(:local).with(includes("git remote add origin git@example.com:repo.git"))
    Cmd.expects(:local).with(includes("git push -f origin master"))

    GitOriginPatch.always
  ensure
    ENV["ORIGIN_REPO"] = ""
  end
end
