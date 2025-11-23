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
    job.expects(:cmd).with("export AWS_ACCESS_KEY_ID=test_access_key; export AWS_SECRET_ACCESS_KEY=test_secret_key; export AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED; export AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED; aws --endpoint-url https://s3.example.com s3 ls s3://test-bucket/").returns("")
    job.perform
  end

  def test_perform_removes_old_backups
    job = DbBackupJob.new

    # Stub backup commands
    job.stubs(:cmd).with(regexp_matches(/pg_dump/)).returns("")
    job.stubs(:cmd).with(regexp_matches(/s3 cp/)).returns("")
    job.stubs(:cmd).with(regexp_matches(/rm -f(?!.*s3)/)).returns("") # rm -f local file

    old_time = 61.days.ago
    new_time = 59.days.ago
    ls_output = <<~OUTPUT
      #{old_time.strftime('%Y-%m-%d %H:%M:%S')} 1234 old_backup.sql
      #{new_time.strftime('%Y-%m-%d %H:%M:%S')} 1234 new_backup.sql
      PRE folder/
    OUTPUT

    # Expect ls command
    job.expects(:cmd).with(regexp_matches(/s3 ls/)).returns(ls_output)

    # Expect removal of old backup
    job.expects(:cmd).with(regexp_matches(/s3 rm .*old_backup.sql/)).returns("")

    # Should not remove new backup
    job.expects(:cmd).with(regexp_matches(/s3 rm .*new_backup.sql/)).never

    job.perform
  end
end
