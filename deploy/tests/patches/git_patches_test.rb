require_relative "../test_helper"

class GitOriginPatchTest < Minitest::Test
  def test_skips_blank_repositories
    Constants.stubs(:origin_repo).returns("")
    Constants.stubs(:origin_repo_backup).returns(" ")

    GitOriginPatch.always
  end

  def test_pushes_configured_repository
    Constants.stubs(:origin_repo).returns("git@example.com:repo.git")
    Constants.stubs(:origin_repo_backup).returns("")
    Constants.stubs(:ssh_key_path).returns("/key")
    Cmd.expects(:local).with("GIT_SSH_COMMAND='ssh -i /key' git remote remove origin").raises("missing")
    Cmd.expects(:local).with("GIT_SSH_COMMAND='ssh -i /key' git remote add origin git@example.com:repo.git")
    Cmd.expects(:local).with("GIT_SSH_COMMAND='ssh -i /key' git push -f origin master")

    GitOriginPatch.always
  end
end

class GitDeploymentPatchTest < Minitest::Test
  def setup
    Constants.stubs(:local_root).returns("/local")
    Constants.stubs(:local_git_dir).returns("/local/repo.git")
    Constants.stubs(:remote_git_dir).returns("/home/deploy/repo.git")
    Constants.stubs(:remote_root).returns("/var/www/app")
    Constants.stubs(:deploy_user).returns("deploy")
    Constants.stubs(:ssh_key_path).returns("/key")
    Instance.stubs(:ip).returns("1.2.3.4")
  end

  def test_existing_deployment_updates_checkout
    GitDeploymentPatch.stubs(:remote_git_exists?).returns(true)
    GitDeploymentPatch.stubs(:remote_root_exists?).returns(true)
    Cmd.expects(:local).with('GIT_SSH_COMMAND="ssh -i /key" git remote remove deployment')
    Cmd.expects(:local).with('GIT_SSH_COMMAND="ssh -i /key" git remote add deployment deploy@1.2.3.4:/home/deploy/repo.git')
    Cmd.expects(:local).with('GIT_SSH_COMMAND="ssh -i /key" git push -f deployment master')
    Cmd.expects(:ssh).with("sudo mkdir -p /var/www/app")
    Cmd.expects(:ssh).with("sudo chown -R deploy:deploy /var/www/app")
    Cmd.expects(:ssh).with("cd /var/www/app && git fetch")
    Cmd.expects(:ssh).with("cd /var/www/app && git checkout -- .")
    Cmd.expects(:ssh).with("cd /var/www/app && git reset --hard origin/master")

    GitDeploymentPatch.always
  end

  def test_missing_deployment_creates_bare_and_remote_repositories
    GitDeploymentPatch.stubs(:remote_git_exists?).returns(false)
    GitDeploymentPatch.stubs(:remote_root_exists?).returns(false)
    Cmd.stubs(:local)
    Cmd.stubs(:ssh)
    Cmd.expects(:local).with("ssh-keygen -R 1.2.3.4")
    Cmd.expects(:local).with("ssh-keyscan -H 1.2.3.4 >> ~/.ssh/known_hosts")
    Cmd.expects(:local).with("git clone --bare /local /local/repo.git")
    Cmd.expects(:ssh).with("git clone /home/deploy/repo.git /var/www/app")

    GitDeploymentPatch.always
  end
end
