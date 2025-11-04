require_relative "lib/require"

system("ssh -i #{$constants.ssh_key_path} -t #{$constants.deploy_user}@#{$instance.ip}")
