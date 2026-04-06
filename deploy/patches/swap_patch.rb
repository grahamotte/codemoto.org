class SwapPatch < BasePatch
  SWAP_SIZE = "5G"

  class << self
    def always
      result = Cmd.ssh("sudo swapon --show")
      return if result.present? && result.include?("/swapfile")

      Cmd.ssh("sudo swapoff -a")
      Cmd.ssh("sudo rm -f /swapfile")
      Cmd.ssh("sudo fallocate -l #{SWAP_SIZE} /swapfile")
      Cmd.ssh("sudo chmod 600 /swapfile")
      Cmd.ssh("sudo mkswap /swapfile")
      Cmd.ssh("sudo swapon /swapfile")

      fstab = Cmd.ssh("cat /etc/fstab")
      unless fstab.include?("/swapfile")
        Cmd.ssh("echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab")
      end

      Cmd.ssh("sudo swapon --show")
    end
  end
end
