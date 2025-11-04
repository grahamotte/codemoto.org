class InstanceCreatePatch < BasePatch
  class << self
    def needed?
      !$instance.running?
    end

    def apply
      Cache.clear
      $instance.clear
      $instance.create

      loop do
        break if instance_ready?
        sleep 4
      end

      Cmd.local("ssh-keygen -R #{$instance.ip}")
      Cmd.local("ssh-keygen -R #{$constants.domain}")
      begin
        Cmd.local("ssh-keyscan -H #{$instance.ip} >> ~/.ssh/known_hosts")
        Cmd.local("ssh-keyscan -H #{$constants.domain} >> ~/.ssh/known_hosts")
      rescue StandardError
      end
    end

    private

    def instance_ready?
      $instance.clear
      return false unless $instance.running?

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
