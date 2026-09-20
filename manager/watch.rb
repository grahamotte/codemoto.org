require_relative "lib/require"

begin
  Linear.sync_statuses
rescue Faraday::Error => error
  puts error.full_message
end

loop do
  Watch.call
  sleep 60
end
