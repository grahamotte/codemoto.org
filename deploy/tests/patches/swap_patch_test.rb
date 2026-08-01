require_relative "../test_helper"

class SwapPatchTest < Minitest::Test
  def test_skips_existing_swap
    Cmd.expects(:ssh).with("sudo swapon --show").returns("/swapfile")

    SwapPatch.always
  end

  def test_creates_swap_and_fstab_entry
    Cmd.expects(:ssh).with("sudo swapon --show").twice.returns("", "/swapfile")
    Cmd.expects(:ssh).with("sudo swapoff -a")
    Cmd.expects(:ssh).with("sudo rm -f /swapfile")
    Cmd.expects(:ssh).with("sudo fallocate -l 5G /swapfile")
    Cmd.expects(:ssh).with("sudo chmod 600 /swapfile")
    Cmd.expects(:ssh).with("sudo mkswap /swapfile")
    Cmd.expects(:ssh).with("sudo swapon /swapfile")
    Cmd.expects(:ssh).with("cat /etc/fstab").returns("")
    Cmd.expects(:ssh).with("echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab")

    SwapPatch.always
  end
end
