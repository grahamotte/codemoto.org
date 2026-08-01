require_relative "../test_helper"

class ConstantsTest < Minitest::Test
  def test_paths
    Constants.stubs(:domain).returns("example.com")
    Constants.stubs(:deploy_user).returns("deploy")

    assert_equal "/var/www/example.com", Constants.remote_root
    assert_equal "/home/deploy", Constants.remote_home_dir
    assert_equal "/home/deploy/example.com.git", Constants.remote_git_dir
    assert_equal "/var/www/example.com/.env", Constants.remote_env_path
    assert_equal "/var/www/example.com/.env.production", Constants.remote_env_prod_path
    assert_equal File.join(Constants.local_root, ".env.production"), Constants.local_env_path
  end

  def test_optional_repositories_default_to_blank
    ENV.delete("ORIGIN_REPO")
    ENV.delete("ORIGIN_REPO_BACKUP")

    assert_equal "", Constants.origin_repo
    assert_equal "", Constants.origin_repo_backup
  end
end
