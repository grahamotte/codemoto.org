require_relative "lib/require"

loop do
  Trigger.call
  sleep 60
end
