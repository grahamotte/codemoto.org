require_relative "lib/require"

cmd = [
  "ssh",
  "-t",
  "-i",
  $constants.ssh_key_path,
  "#{$constants.deploy_user}@#{$instance.ip}",
  "'cd #{$constants.remote_root}/backend && set -a && source ../.env && mise exec -- rails console'",
]
puts cmd.join(" ")
system(cmd.join(" "))
