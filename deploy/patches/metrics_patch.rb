class MetricsPatch < BasePatch
  class << self
    def needed?
      !Instance.service_running?("do-agent")
    end

    def apply
      Cmd.ssh("curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash")
    end
  end
end
