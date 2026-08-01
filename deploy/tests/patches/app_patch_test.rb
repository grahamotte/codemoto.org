require_relative "../test_helper"

class AppPatchTest < Minitest::Test
  def setup
    Constants.stubs(:remote_root).returns("/app")
    Constants.stubs(:deploy_user).returns("deploy")
    Constants.stubs(:domain).returns("example.com")
    Cache.stubs(:if_files_changed)
    Instance.stubs(:stop_service)
    Instance.stubs(:write_service)
    Cmd.stubs(:ssh)
    Subdomains.stubs(:frontends).returns([ { name: "www" } ])
    Req.stubs(:call)
  end

  def test_always_restarts_services_builds_frontends_and_pings
    Instance.expects(:stop_service).with("api")
    Instance.expects(:stop_service).with("job")
    Instance.expects(:write_service).with("api", includes("Description=Api"))
    Instance.expects(:write_service).with("job", includes("Description=Job Worker"))
    Cmd.expects(:ssh).with("rm -rf ~/tmp")
    Cmd.expects(:ssh).with("sudo systemctl start api.service")
    Cmd.expects(:ssh).with("sudo systemctl start job.service")
    Cmd.expects(:ssh).with(includes("VITE_SUBDOMAIN=www"))
    Req.expects(:call).with(method: :get, url: "https://example.com/api/noop/ping")

    AppPatch.always
  end

  def test_changed_dependencies_and_migrations_run_commands
    Cache.stubs(:if_files_changed).yields
    Cmd.expects(:ssh).with("cd /app/frontend; mise exec -- pnpm install --frozen-lockfile")
    Cmd.expects(:ssh).with("cd /app/backend; mise exec -- bundle install")
    Cmd.expects(:ssh).with("cd /app/backend; set -a; source ../.env; mise exec -- bin/rails db:migrate")

    AppPatch.always
  end

  def test_service_definitions
    assert_includes AppPatch.send(:api_service), "User=deploy"
    assert_includes AppPatch.send(:api_service), "rails server --port 3000"
    assert_includes AppPatch.send(:job_service), "GOOD_JOB_ENABLE_CRON=true"
    assert_includes AppPatch.send(:job_service), "good_job start"
  end
end
