require_relative "lib/require"

code = ARGV.join(" ").strip

if code.blank?
  warn "Usage: mise runner:production \"User.first\""
  exit 1
end

Cmd.ssh(
  "cd ? && set -a && source ../.env && RAILS_ENV=production mise exec -- bundle exec rails runner ?",
  File.join(Constants.remote_root, "backend"),
  code,
)
