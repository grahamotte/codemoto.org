require_relative "../test_helper"

class UpdatePatchTest < Minitest::Test
  def test_always_updates_packages
    Cmd.expects(:ssh).with("sudo apt-get update -y")
    Cmd.expects(:ssh).with("sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y")

    UpdatePatch.always
  end
end
