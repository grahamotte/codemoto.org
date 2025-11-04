class GitOriginPatch < BasePatch
  class << self
    def always
      Cmd.local("GIT_SSH_COMMAND='ssh -i #{$constants.ssh_key_path}' git remote remove origin") rescue StandardError
      Cmd.local("GIT_SSH_COMMAND='ssh -i #{$constants.ssh_key_path}' git remote add origin #{$constants.origin_repo}")
      Cmd.local("GIT_SSH_COMMAND='ssh -i #{$constants.ssh_key_path}' git push -f origin master")
    end
  end
end
