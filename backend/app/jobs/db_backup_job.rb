class DbBackupJob < ApplicationJob
  schedule "every 1 day"

  include Sentry::Cron::MonitorCheckIns
  sentry_monitor_check_ins

  def perform
    timestamp = Time.now.to_i
    access_key_id = ENV.fetch("BACKUP_ACCESS_KEY_ID")
    secret_access_key = ENV.fetch("BACKUP_SECRET_ACCESS_KEY")
    db_name = ENV.fetch("DB_NAME")
    deploy_user = ENV.fetch("DEPLOY_USER")
    endpoint = ENV.fetch("BACKUP_ENDPOINT")
    bucket = ENV.fetch("BACKUP_BUCKET")
    key = "#{db_name}_#{timestamp}.sql"
    path = File.join("/home/#{deploy_user}", key)
    exports = [
      "export AWS_ACCESS_KEY_ID=#{access_key_id};",
      "export AWS_SECRET_ACCESS_KEY=#{secret_access_key};",
      "export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED;",
      "export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED;",
    ].join(" ")

    cmd("/usr/bin/pg_dump -U #{deploy_user} --clean #{db_name} > #{path}")
    cmd("#{exports} aws --endpoint-url #{endpoint} s3 cp #{path} s3://#{bucket}/#{key}")
    cmd("rm -f #{path}")

    head_output = cmd("#{exports} aws --endpoint-url #{endpoint} s3api head-object --bucket #{bucket} --key #{key}")
    byte_count = head_output.match(/"ContentLength":\s*(\d+)/)&.captures&.first.to_i
    raise "Backup #{key} missing or empty (#{byte_count} bytes)" unless byte_count.positive?

    keep_backups_for = 60.days
    all_backups = cmd("#{exports} aws --endpoint-url #{endpoint} s3 ls s3://#{bucket}/#{db_name}_")
      .split("\n")
      .map { |x| x.split.last }
      .select { |x| x.start_with?("#{db_name}_") && x.end_with?(".sql") }
    outdated_backups = all_backups
      .select { |x| x.rpartition('_').last.gsub(".sql", "").to_i < keep_backups_for.ago.to_i }

    outdated_backups.each do |backup|
      cmd("#{exports} aws --endpoint-url #{endpoint} s3 rm s3://#{bucket}/#{backup}")
    end
  rescue => e
    Notify.call(":rotating_light: *DB BACKUP FAILED* :rotating_light:\n```#{e.message}```")
    raise
  end

  def cmd(command)
    puts command unless X.test?
    `#{command}`
  end
end
