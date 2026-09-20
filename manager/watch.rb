require_relative "lib/require"

loop do
  Linear.sync_statuses
  Trigger.call
  sleep 60
end
