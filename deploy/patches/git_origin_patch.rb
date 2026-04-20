class GitOriginPatch < BasePatch
  class << self
    def always
      push_to("origin", Constants.origin_repo)
      push_to("origin_backup", Constants.origin_repo_backup)
    end

    private

    def push_to(remote, repo)
      return if repo.to_s.strip.empty?

      Cmd.local("GIT_SSH_COMMAND='ssh -i #{Constants.ssh_key_path}' git remote remove #{remote}") rescue StandardError
      Cmd.local("GIT_SSH_COMMAND='ssh -i #{Constants.ssh_key_path}' git remote add #{remote} #{repo}")
      Cmd.local("GIT_SSH_COMMAND='ssh -i #{Constants.ssh_key_path}' git push -f #{remote} master")
    end
  end
end
