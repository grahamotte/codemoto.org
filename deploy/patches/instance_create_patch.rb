class InstanceCreatePatch < BasePatch
  class << self
    def needed?
      !Instance.running?
    end

    def apply
      Cache.clear
      Instance.clear
      Instance.create

      loop do
        break if instance_ready?
        sleep 4
      end

      Cmd.local("ssh-keygen -R #{Instance.ip}")
      Cmd.local("ssh-keygen -R #{Constants.domain}")
      begin
        Cmd.local("ssh-keyscan -H #{Instance.ip} >> ~/.ssh/known_hosts")
        Cmd.local("ssh-keyscan -H #{Constants.domain} >> ~/.ssh/known_hosts")
      rescue StandardError
      end
    end

    private

    def instance_ready?
      Instance.clear
      return false unless Instance.running?

      begin
        res = Cmd.ssh("echo !ass!tits!", user: "root")
        res.include?("!ass!tits!")
      rescue StandardError => e
        puts e.message
        false
      end
    end
  end
end
