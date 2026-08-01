require_relative "../test_helper"

class DbBackupPatchTest < Minitest::Test
  def test_backup_installs_aws_uploads_and_removes_dump
    Instance.stubs(:installed?).with("aws").returns(false)
    Constants.stubs(:db_name).returns("app")
    Constants.stubs(:remote_home_dir).returns("/home/deploy")
    Constants.stubs(:deploy_user).returns("deploy")
    Constants.stubs(:backup_access_key_id).returns("access")
    Constants.stubs(:backup_secret_access_key).returns("secret")
    Constants.stubs(:backup_endpoint).returns("https://storage")
    Constants.stubs(:backup_bucket).returns("backups")
    Time.stubs(:now).returns(Time.at(123))
    Cmd.expects(:ssh).with("sudo apt-get install -y awscli")
    Cmd.expects(:ssh).with("/usr/bin/pg_dump -U deploy --clean app > /home/deploy/app_123.sql")
    Cmd.expects(:ssh).with(includes("aws --endpoint-url https://storage s3 cp /home/deploy/app_123.sql s3://backups/app_123.sql"))
    Cmd.expects(:ssh).with("rm -f /home/deploy/app_123.sql")

    DbBackupPatch.always
  end
end

class DbRestorePatchTest < Minitest::Test
  def test_restore_latest_backup
    Instance.stubs(:installed?).with("aws").returns(true)
    Constants.stubs(:db_name).returns("app")
    Constants.stubs(:remote_home_dir).returns("/home/deploy")
    Constants.stubs(:backup_bucket).returns("backups")
    DbRestorePatch.stubs(:backup_keys).returns([ "app_1.sql", "app_2.sql" ])
    DbRestorePatch.expects(:aws_cmd).with("s3 cp s3://backups/app_2.sql /home/deploy/app_2.sql")
    Cmd.expects(:ssh).with("psql app < /home/deploy/app_2.sql")
    Instance.expects(:start_service).with(:postgresql)
    Cmd.expects(:ssh).with("rm -f /home/deploy/app_2.sql")

    DbRestorePatch.always
  end

  def test_backup_keys_filters_and_sorts_database_backups
    Constants.stubs(:db_name).returns("app")
    Constants.stubs(:backup_bucket).returns("backups")
    DbRestorePatch.stubs(:aws_cmd).returns(<<~TEXT)
      2026-01-01 1 other_1.sql
      2026-01-02 1 app_2.sql
      2026-01-03 1 app_1.sql
    TEXT

    assert_equal [ "app_1.sql", "app_2.sql" ], DbRestorePatch.send(:backup_keys)
  end
end

class PostgresPatchTest < Minitest::Test
  def test_needed_for_missing_components
    Instance.stubs(:not_installed?).with("psql").returns(true)
    assert PostgresPatch.needed?

    Instance.stubs(:not_installed?).with("psql").returns(false)
    PostgresPatch.stubs(:user_exists?).returns(true)
    PostgresPatch.stubs(:db_exists?).returns(true)
    refute PostgresPatch.needed?
  end

  def test_apply_configures_existing_postgres
    Instance.stubs(:not_installed?).with("psql").returns(false)
    PostgresPatch.stubs(:user_exists?).returns(true)
    PostgresPatch.stubs(:db_exists?).returns(true)
    Cmd.expects(:ssh_write)
      .with("/etc/postgresql/18/main/pg_hba.conf", includes("127.0.0.1/32"), sudo: true)
    Instance.expects(:restart_service).with("postgresql")

    PostgresPatch.apply
  end

  def test_apply_installs_postgres_and_creates_user_and_database
    Instance.stubs(:not_installed?).with("psql").returns(true)
    PostgresPatch.stubs(:user_exists?).returns(false)
    PostgresPatch.stubs(:db_exists?).returns(false)
    Constants.stubs(:deploy_user).returns("deploy")
    Constants.stubs(:db_name).returns("app")
    Cmd.stubs(:ssh)
    Cmd.stubs(:ssh_write)
    Instance.expects(:start_service).with("postgresql")
    Cmd.expects(:ssh).with("sudo -u postgres createuser -s deploy")
    Cmd.expects(:ssh).with("sudo -u postgres createdb app")
    Instance.expects(:restart_service).with("postgresql")

    PostgresPatch.apply
  end

  def test_existence_checks_handle_results_and_failures
    Constants.stubs(:deploy_user).returns("deploy")
    Constants.stubs(:db_name).returns("app")
    Cmd.expects(:ssh).returns("asstits")
    assert PostgresPatch.send(:user_exists?)

    Cmd.expects(:ssh).raises("failure")
    refute PostgresPatch.send(:db_exists?)
  end
end
