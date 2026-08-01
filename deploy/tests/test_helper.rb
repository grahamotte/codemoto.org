require "bundler/setup"
require "minitest/autorun"
require "minitest/parallel_fork"
require "mocha/minitest"
require "webmock/minitest"
require "test_safety"
require "tmpdir"
WebMock.disable_net_connect!
def Minitest.parallel_fork_number = 4

require_relative "../lib/require"

module DeployTestMethods
  CMD_LOCAL = Cmd.method(:local)
  REQ_CALL = Req.method(:call)
end

[ BasePatch, Cloudflare, Instance ].each do |klass|
  klass.define_singleton_method(:puts) { |*| }
end

Cmd.define_singleton_method(:local) { |*, **| raise UnsafeTestOperation, "Cmd.local must be stubbed in deploy tests" }
Cmd.define_singleton_method(:ssh) { |*, **| raise UnsafeTestOperation, "Cmd.ssh must be stubbed in deploy tests" }
Cmd.define_singleton_method(:ssh_write) { |*, **| raise UnsafeTestOperation, "Cmd.ssh_write must be stubbed in deploy tests" }
Req.define_singleton_method(:call) { |*, **| raise UnsafeTestOperation, "Req.call must be stubbed in deploy tests" }
Net::SSH.define_singleton_method(:start) { |*, **| raise UnsafeTestOperation, "Net::SSH.start must be stubbed in deploy tests" }

{
  "BACKUP_ACCESS_KEY_ID" => "access",
  "BACKUP_BUCKET" => "backups",
  "BACKUP_ENDPOINT" => "https://storage.example.com",
  "BACKUP_SECRET_ACCESS_KEY" => "secret",
  "CLOUDFLARE_TOKEN" => "cloudflare-token",
  "DB_NAME" => "app",
  "DEPLOY_PASSWORD" => "password",
  "DEPLOY_SSH_KEY" => "private-key",
  "DEPLOY_SSH_KEY_FINGERPRINT" => "fingerprint",
  "DEPLOY_SSH_KEY_PUB" => "public-key",
  "DEPLOY_USER" => "deploy",
  "DIGITAL_OCEAN_TOKEN" => "digital-ocean-token",
  "DOMAIN" => "example.com",
  "INSTANCE_REGION" => "test-region",
  "INSTANCE_SIZE" => "test-size",
  "ORIGIN_REPO" => "",
  "ORIGIN_REPO_BACKUP" => "",
  "test" => "true",
}.each { |key, value| ENV[key] = value }

module DeployTestIsolation
  def before_setup
    @deploy_test_dir = Dir.mktmpdir
    $cache = Cache.new(dir: File.join(@deploy_test_dir, "cache"))
    Constants.instance_variable_set(:@ssh_key_path, File.join(@deploy_test_dir, "id_rsa"))
    Instance.clear
    Cloudflare.instance_variable_set(:@zone_id, nil)
    Subdomains.instance_variable_set(:@all, nil)
    DependenciesPatch.instance_variable_set(:@current_versions, nil)
    CertPatch.instance_variable_set(:@certificate, nil)
    super
  end

  def after_teardown
    FileUtils.rm_rf(@deploy_test_dir)
    super
  end
end

Minitest::Test.prepend(DeployTestIsolation)
