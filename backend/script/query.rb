require_relative "../config/environment"

query = ARGV.join(" ").strip

if query.blank?
  warn "Usage: mise query \"select * from table_name\""
  exit 1
end

result = ActiveRecord::Base.connection.exec_query(query)
puts JSON.pretty_generate(result.rows.map { |r| result.columns.zip(r).to_h })
