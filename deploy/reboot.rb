require_relative "lib/require"

puts ""
puts "////// Rebooting Instance //////".magenta
puts ""

raise "No running instance found" unless Instance.running?

puts "Power cycling droplet #{Instance.instance_id}...".cyan

Instance.send(:req, :post, "droplets/#{Instance.instance_id}/actions", payload: { type: "power_cycle" })

puts ""
puts "Power cycle initiated.".green
puts ""
