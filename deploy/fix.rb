require_relative "lib/require"

cmd = [
  "ssh",
  "-t",
  "-i",
  Constants.ssh_key_path,
  "#{Constants.deploy_user}@#{Instance.ip}",
  "'cd #{Constants.remote_root}/backend && set -a && source ../.env && mise exec -- rails console'",
]
puts cmd.join(" ")
system(cmd.join(" "))
