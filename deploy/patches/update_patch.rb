class UpdatePatch < BasePatch
  class << self
    def always
      Cmd.ssh("sudo apt-get update -y")
      Cmd.ssh("sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y")
    end
  end
end
