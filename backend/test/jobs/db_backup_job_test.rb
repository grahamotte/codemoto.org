require "test_helper"

class DbBackupJobTest < ActiveSupport::TestCase
  def setup
    ENV["BACKUP_ACCESS_KEY_ID"] = "test_access_key"
    ENV["BACKUP_SECRET_ACCESS_KEY"] = "test_secret_key"
    ENV["DB_NAME"] = "test_db"
    ENV["DEPLOY_USER"] = "deploy"
    ENV["BACKUP_ENDPOINT"] = "https://s3.example.com"
    ENV["BACKUP_BUCKET"] = "test-bucket"
  end

  def teardown
    %w[
      BACKUP_ACCESS_KEY_ID
      BACKUP_SECRET_ACCESS_KEY
      DB_NAME
      DEPLOY_USER
      BACKUP_ENDPOINT
      BACKUP_BUCKET
    ].each { |key| ENV.delete(key) }
  end

  def test_perform
    commands = []
    outdated = "test_db_#{61.days.ago.to_i}.sql"
    recent = "test_db_#{1.day.ago.to_i}.sql"
    job = DbBackupJob.new
    job.define_singleton_method(:cmd) do |command|
      commands << command
      next '{"ContentLength": 12345}' if command.include?("head-object")
      next "2026-01-01 1 #{outdated}\n2026-01-02 1 #{recent}" if command.include?(" s3 ls ")

      ""
    end

    job.perform

    dump = commands.find { |command| command.include?("pg_dump") }
    key = dump.match(%r{/home/deploy/(test_db_\d+\.sql)})[1]
    assert_includes dump, "-U deploy --clean test_db"
    assert commands.any? { |command| command.include?("s3 cp /home/deploy/#{key} s3://test-bucket/#{key}") }
    assert_includes commands, "rm -f /home/deploy/#{key}"
    assert commands.any? { |command| command.include?("head-object --bucket test-bucket --key #{key}") }
    assert commands.any? { |command| command.end_with?("s3 rm s3://test-bucket/#{outdated}") }
    refute commands.any? { |command| command.end_with?("s3 rm s3://test-bucket/#{recent}") }
  end

  def test_perform_rejects_empty_backup
    job = DbBackupJob.new
    job.define_singleton_method(:cmd) do |command|
      command.include?("head-object") ? '{"ContentLength": 0}' : ""
    end

    assert_raises(RuntimeError) { job.perform }
  end
end
