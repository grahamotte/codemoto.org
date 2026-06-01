require_relative "lib/require"

code = ARGV.join(" ").strip

if code.blank?
  warn "Usage: mise runner:production \"User.first\""
  exit 1
end

Cmd.ssh(
  "cd ? && RAILS_ENV=production bundle exec rails runner ?",
  Constants.remote_root,
  code,
)
