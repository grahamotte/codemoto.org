require_relative "lib/require"

cmd = [
  "ssh",
  "-t",
  "-i",
  $constants.ssh_key_path,
  "#{$constants.deploy_user}@#{$instance.ip}",
  'htop',
]
puts cmd.join(" ")
system(cmd.join(" "))
