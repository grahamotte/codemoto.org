require_relative "lib/require"

loop do
  Watch.call
  sleep 60
end
