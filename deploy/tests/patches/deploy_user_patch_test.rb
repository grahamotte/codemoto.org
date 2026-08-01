require_relative "../test_helper"

class DeployUserPatchTest < Minitest::Test
  def test_needed
    Cmd.expects(:ssh).returns("ok")
    refute DeployUserPatch.needed?

    Cmd.expects(:ssh).raises("failure")
    assert DeployUserPatch.needed?
  end

  def test_apply_creates_and_secures_user
    Constants.stubs(:deploy_user).returns("deploy")
    Constants.stubs(:deploy_password).returns("password")
    Constants.stubs(:ssh_key).returns("private")
    Constants.stubs(:ssh_key_pub).returns("public")
    Cmd.stubs(:ssh)
    Cmd.stubs(:ssh_write)
    Cmd.expects(:ssh).with("useradd deploy -m", user: "root")
    Cmd.expects(:ssh).with("yes password | passwd deploy", user: "root")
    Cmd.expects(:ssh_write).with("/home/deploy/.ssh/id_rsa", "private", user: "root")
    Cmd.expects(:ssh_write).with("/home/deploy/.ssh/id_rsa.pub", "public", user: "root")
    Cmd.expects(:ssh_write).with("/etc/ssh/sshd_config", includes("PermitRootLogin no"), user: "root")
    Cmd.expects(:ssh).with("systemctl restart ssh", user: "root")

    DeployUserPatch.apply
  end
end
