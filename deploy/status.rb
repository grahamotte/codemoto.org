require_relative "lib/require"

puts ""
puts "////// Deployment Status //////".magenta
puts ""

puts "#{"Domain:".ljust(20)} #{Constants.domain}".cyan
puts "#{"Instance Running:".ljust(20)} #{Instance.running? ? "Yes".green : "No".red}"

if Instance.running?
  puts "#{"IP Address:".ljust(20)} #{Instance.ip}".cyan
  puts "#{"Region:".ljust(20)} #{Constants.instance_region}".cyan
  puts "#{"Size:".ljust(20)} #{Constants.instance_size}".cyan
  puts ""

  puts "Services".magenta

  services = ["app", "job", "nginx", "postgresql"]

  services.each do |service|
    running = Instance.service_running?(service)
    status = running ? "Running".green : "Stopped".red
    puts "  #{service.ljust(15)}: #{status}"
  end

  puts ""
  puts "System Info".magenta

  uptime = Cmd.ssh("uptime -p").strip
  puts "  #{"Uptime:".ljust(15)} #{uptime}"

  memory = Cmd.ssh("free -h | grep Mem").strip.split
  puts "  #{"Memory:".ljust(15)} #{memory[2]} used / #{memory[1]} total"

  disk = Cmd.ssh("df -h / | tail -1").strip.split
  puts "  #{"Disk:".ljust(15)} #{disk[2]} used / #{disk[1]} total (#{disk[4]} usage)"

  puts ""
  puts "Application".magenta

  git_branch = Cmd.ssh("cd #{Constants.remote_root} && git rev-parse --abbrev-ref HEAD").strip
  git_commit = Cmd.ssh("cd #{Constants.remote_root} && git rev-parse --short HEAD").strip
  git_date = Cmd.ssh("cd #{Constants.remote_root} && git log -1 --format=%cd --date=relative").strip

  puts "  #{"Branch:".ljust(15)} #{git_branch}"
  puts "  #{"Commit:".ljust(15)} #{git_commit}"
  puts "  #{"Last Deploy:".ljust(15)} #{git_date}"

else
  puts ""
  puts "No active deployment found.".red
end

puts ""

