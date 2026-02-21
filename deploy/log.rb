require_relative "lib/require"

cmd = [
  "ssh",
  "-t",
  "-i",
  Constants.ssh_key_path,
  "#{Constants.deploy_user}@#{Instance.ip}",
  "sudo journalctl -f -u api",
]
puts cmd.join(" ")
system(cmd.join(" "))
