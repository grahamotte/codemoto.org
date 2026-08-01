require_relative "../test_helper"

class DbRestorePatchTest < Minitest::Test
  def test_always_restores_latest_backup
    commands = []
    Cmd.stubs(:ssh).with do |command, *|
      commands << command
      command != "which aws" && !command.include?("s3 ls") && !command.start_with?("systemctl show")
    end.returns("")
    Cmd.expects(:ssh).with("which aws").returns("/usr/bin/aws")
    Cmd.expects(:ssh).with(includes("s3 ls")).returns("2026-01-01 1 other_1.sql\n2026-01-02 1 app_2.sql\n2026-01-03 1 app_1.sql")
    Cmd.expects(:ssh).with(regexp_matches(/\Asystemctl show/))
      .returns("LoadState=loaded\nActiveState=active\nFreezerState=running\n")

    DbRestorePatch.always

    assert commands.any? { |command| command.include?("s3 cp s3://backups/app_2.sql /home/deploy/app_2.sql") }
    assert_includes commands, "psql app < /home/deploy/app_2.sql"
    assert_includes commands, "sudo systemctl start postgresql.service"
    assert_includes commands, "rm -f /home/deploy/app_2.sql"
  end

  def test_backup_keys_filters_and_sorts
    Cmd.stubs(:ssh).returns(<<~TEXT)
      2026-01-01 1 other_1.sql
      2026-01-02 1 app_2.sql
      2026-01-03 1 app_1.sql
    TEXT

    assert_equal [ "app_1.sql", "app_2.sql" ], DbRestorePatch.send(:backup_keys)
  end
end
