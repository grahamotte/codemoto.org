require_relative "lib/require"

system("ssh -i #{Constants.ssh_key_path} -t #{Constants.deploy_user}@#{Instance.ip}")
