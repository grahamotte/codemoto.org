class UpdatePatch < BasePatch
  class << self
    def always
      repair_postgres_source
      Cmd.ssh("sudo apt-get update -y")
      Cmd.ssh("sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y")
    end

    private

    def repair_postgres_source
      Cmd.ssh(
        "if [ -f /etc/apt/sources.list.d/pgdg.list ] && " \
        "! curl --fail --silent --head https://apt.postgresql.org/pub/repos/apt/dists/$(lsb_release -cs)-pgdg/Release > /dev/null; then " \
        "sudo sed -i 's|https://apt.postgresql.org|https://apt-archive.postgresql.org|' /etc/apt/sources.list.d/pgdg.list; " \
        "fi",
      )
    end
  end
end
