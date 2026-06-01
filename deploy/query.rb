require_relative "lib/require"
require "csv"
require "json"

query = ARGV.join(" ").strip

if query.blank?
  warn "Usage: mise deploy:query \"select count(*) from table_name\""
  exit 1
end

unless /\A\s*(select|with|show|explain|table|values)\b/i.match?(query)
  warn "Only read-only query forms are allowed: SELECT, WITH, SHOW, EXPLAIN, TABLE, VALUES"
  exit 1
end

output = Cmd.ssh(
  [
    "PGOPTIONS='-c default_transaction_read_only=on'",
    "psql",
    "-X",
    "-v ON_ERROR_STOP=1",
    "-P pager=off",
    "--csv",
    "-U ?",
    "-d ?",
    "-c ?",
  ].join(" "),
  Constants.deploy_user,
  Constants.db_name,
  query,
  quiet: true,
)

csv = CSV.parse(output, headers: true)
puts JSON.pretty_generate(csv.map(&:to_h))
