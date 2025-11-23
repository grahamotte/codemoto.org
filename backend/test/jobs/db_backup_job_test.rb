require "test_helper"

class DbBackupJobTest < ActiveSupport::TestCase
  def setup
    Time.stubs(:now).returns(Time.at(1_234_567_890))
    ENV["BACKUP_ACCESS_KEY_ID"] = "test_access_key"
    ENV["BACKUP_SECRET_ACCESS_KEY"] = "test_secret_key"
    ENV["DB_NAME"] = "test_db"
    ENV["DEPLOY_USER"] = "deploy"
    ENV["BACKUP_ENDPOINT"] = "https://s3.example.com"
    ENV["BACKUP_BUCKET"] = "test-bucket"
  end

  def teardown
    ENV.delete("BACKUP_ACCESS_KEY_ID")
    ENV.delete("BACKUP_SECRET_ACCESS_KEY")
    ENV.delete("DB_NAME")
    ENV.delete("DEPLOY_USER")
    ENV.delete("BACKUP_ENDPOINT")
    ENV.delete("BACKUP_BUCKET")
  end

  def test_perform_generates_correct_commands
    job = DbBackupJob.new
    job.expects(:cmd).with("/usr/bin/pg_dump -U deploy --clean test_db > /home/deploy/test_db_1234567890.sql").returns("")
    job.expects(:cmd).with("export AWS_ACCESS_KEY_ID=test_access_key; export AWS_SECRET_ACCESS_KEY=test_secret_key; export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED; export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED; aws --endpoint-url https://s3.example.com s3 cp /home/deploy/test_db_1234567890.sql s3://test-bucket/test_db_1234567890.sql").returns("")
    job.expects(:cmd).with("rm -f /home/deploy/test_db_1234567890.sql").returns("")
    job.expects(:cmd).with("export AWS_ACCESS_KEY_ID=test_access_key; export AWS_SECRET_ACCESS_KEY=test_secret_key; export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED; export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED; aws --endpoint-url https://s3.example.com s3 ls s3://test-bucket/test_db_").returns("")
    job.perform
  end

  def test_perform_removes_old_backups
    job = DbBackupJob.new
    exports = "export AWS_ACCESS_KEY_ID=test_access_key; export AWS_SECRET_ACCESS_KEY=test_secret_key; export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED; export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED;"

    # Standard backup flow expectations
    job.expects(:cmd).with("/usr/bin/pg_dump -U deploy --clean test_db > /home/deploy/test_db_1234567890.sql").returns("")
    job.expects(:cmd).with("#{exports} aws --endpoint-url https://s3.example.com s3 cp /home/deploy/test_db_1234567890.sql s3://test-bucket/test_db_1234567890.sql").returns("")
    job.expects(:cmd).with("rm -f /home/deploy/test_db_1234567890.sql").returns("")

    old_ts = 61.days.ago.to_i
    new_ts = 59.days.ago.to_i

    old_file = "test_db_#{old_ts}.sql"
    new_file = "test_db_#{new_ts}.sql"

    ls_output = <<~OUTPUT
      2023-01-01 12:00:00 1234 #{old_file}
      2023-01-02 12:00:00 1234 #{new_file}
    OUTPUT

    # Expect ls command
    job.expects(:cmd).with("#{exports} aws --endpoint-url https://s3.example.com s3 ls s3://test-bucket/test_db_").returns(ls_output)

    # Expect removal of old backup
    job.expects(:cmd).with("#{exports} aws --endpoint-url https://s3.example.com s3 rm s3://test-bucket/#{old_file}").returns("")

    # Should not remove new backup
    job.expects(:cmd).with("#{exports} aws --endpoint-url https://s3.example.com s3 rm s3://test-bucket/#{new_file}").never

    job.perform
  end
end
