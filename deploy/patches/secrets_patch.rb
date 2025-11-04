class SecretsPatch < BasePatch
  class << self
    def always
      Cache.if_files_changed($constants.local_env_path) do
        Cmd.ssh_write(
          $constants.remote_env_path,
          File.read($constants.local_env_path),
        )
        Cmd.ssh_write(
          $constants.remote_env_prod_path,
          File.read($constants.local_env_path),
        )
        Cmd.ssh_write(
          File.join($constants.remote_home_dir, ".env"),
          File.read($constants.local_env_path),
        )
      end
    end
  end
end
