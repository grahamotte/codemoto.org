class GitDeploymentPatch < BasePatch
  class << self
    def always
      unless remote_git_exists?
        Cmd.local("ssh-keygen -R #{$instance.ip}")
        Cmd.local("ssh-keyscan -H #{$instance.ip} >> ~/.ssh/known_hosts")

        Cmd.local("rm -rf #{$constants.local_git_dir}")
        Cmd.ssh("rm -rf #{$constants.remote_git_dir}")

        Cmd.local("git clone --bare #{$constants.local_root} #{$constants.local_git_dir}")
        Cmd.local("rsync -av -e \"ssh -i #{$constants.ssh_key_path}\" #{$constants.local_git_dir}/ #{$constants.deploy_user}@#{$instance.ip}:#{$constants.remote_git_dir}/")

        Cmd.local("rm -rf #{$constants.local_git_dir}")
      end

      begin
        Cmd.local("GIT_SSH_COMMAND=\"ssh -i #{$constants.ssh_key_path}\" git remote remove deployment")
      rescue StandardError
      end
      Cmd.local("GIT_SSH_COMMAND=\"ssh -i #{$constants.ssh_key_path}\" git remote add deployment #{$constants.deploy_user}@#{$instance.ip}:#{$constants.remote_git_dir}")

      Cmd.local("GIT_SSH_COMMAND=\"ssh -i #{$constants.ssh_key_path}\" git push -f deployment master")

      Cmd.ssh("sudo mkdir -p #{$constants.remote_root}")
      Cmd.ssh("sudo chown -R #{$constants.deploy_user}:#{$constants.deploy_user} #{$constants.remote_root}")

      Cmd.ssh("git clone #{$constants.remote_git_dir} #{$constants.remote_root}") if !remote_root_exists?

      Cmd.ssh("cd #{$constants.remote_root} && git fetch")
      Cmd.ssh("cd #{$constants.remote_root} && git checkout -- .")
      Cmd.ssh("cd #{$constants.remote_root} && git reset --hard origin/master")
    end

    private

    def remote_git_exists?
      Cmd.ssh("[ -d #{$constants.remote_git_dir} ]")
    rescue StandardError => e
      puts e.message
      false
    end

    def remote_root_exists?
      Cmd.ssh("[ -d #{$constants.remote_root}/.git ]")
    rescue StandardError => e
      puts e.message
      false
    end
  end
end
