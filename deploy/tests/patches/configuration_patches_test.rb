require_relative "../test_helper"

class CertPatchTest < Minitest::Test
  def setup
    CertPatch.instance_variable_set(:@certificate, nil)
  end

  def test_needed_for_missing_expiring_or_wrong_domain_certificate
    CertPatch.stubs(:cert_expires_on).returns(nil)
    assert CertPatch.needed?

    CertPatch.stubs(:cert_expires_on).returns(Date.today + 30)
    CertPatch.stubs(:certificate_domains).returns([ "other.com" ])
    Subdomains.stubs(:domains).returns([ "example.com" ])
    assert CertPatch.needed?

    CertPatch.stubs(:certificate_domains).returns([ "example.com" ])
    CertPatch.stubs(:cert_expires_on).returns(Date.today + 30)
    refute CertPatch.needed?
  end

  def test_certificate_parsing
    CertPatch.stubs(:certificate).returns("notAfter=Aug 30 00:00:00 2026 GMT\nX509v3 Subject Alternative Name:\n DNS:example.com, DNS:www.example.com")

    assert_equal Date.new(2026, 8, 30), CertPatch.send(:cert_expires_on)
    assert_equal [ "example.com", "www.example.com" ], CertPatch.send(:certificate_domains)
  end

  def test_apply
    Constants.stubs(:domain).returns("example.com")
    Subdomains.stubs(:domains).returns([ "example.com", "www.example.com" ])
    CertPatch.stubs(:default_nginx_conf).returns("nginx")
    Instance.expects(:install_package).with("nginx")
    Instance.expects(:stop_service).with("nginx").twice
    Cmd.expects(:ssh_write).with("/etc/nginx/nginx.conf", "nginx", sudo: true)
    Cmd.expects(:ssh).with("sudo fuser -k 80/tcp || true")
    Instance.expects(:start_service).with("nginx")
    Cmd.expects(:ssh).with("sudo nginx -t")
    Instance.stubs(:not_installed?).with("certbot").returns(true)
    Cmd.expects(:ssh).with("sudo snap install --classic certbot")
    Cmd.expects(:ssh).with("sudo ln -s /snap/bin/certbot /usr/bin/certbot")
    Cmd.expects(:ssh).with(regexp_matches(/--cert-name example\.com.*-d example\.com -d www\.example\.com/))

    CertPatch.apply
  end
end

class NginxPatchTest < Minitest::Test
  def setup
    Constants.stubs(:domain).returns("example.com")
    Constants.stubs(:remote_root).returns("/app")
    Subdomains.stubs(:all).returns([
      { name: "www", subdomains: [ "", "www" ], directory: "subdomains/www", backend: false },
      { name: "api", subdomains: [ "api" ], directory: nil, backend: true },
    ])
  end

  def test_nginx_config_has_frontend_and_backend_servers
    config = NginxPatch.send(:nginx_config)

    assert_includes config, "server_name example.com www.example.com api.example.com"
    assert_includes config, "root /app/frontend/dist/www"
    assert_includes config, "location /api/"
    assert_includes config, "server_name api.example.com"
    assert_includes config, "proxy_pass http://localhost:3000"
  end

  def test_always_writes_and_restarts_nginx
    NginxPatch.stubs(:nginx_config).returns("config")
    Instance.expects(:install_package).with("nginx")
    Cmd.expects(:ssh_write).with("/etc/nginx/nginx.conf", "config", sudo: true)
    Instance.expects(:restart_service).with("nginx")

    NginxPatch.always
  end
end

class SecretsPatchTest < Minitest::Test
  def test_writes_each_environment_file_when_changed
    Constants.stubs(:local_env_path).returns("/local/.env")
    Constants.stubs(:remote_env_path).returns("/app/.env")
    Constants.stubs(:remote_env_prod_path).returns("/app/.env.production")
    Constants.stubs(:remote_home_dir).returns("/home/deploy")
    File.stubs(:read).with("/local/.env").returns("SECRET=value")
    Cache.stubs(:if_files_changed).yields
    Cmd.expects(:ssh_write).with("/app/.env", "SECRET=value")
    Cmd.expects(:ssh_write).with("/app/.env.production", "SECRET=value")
    Cmd.expects(:ssh_write).with("/home/deploy/.env", "SECRET=value")

    SecretsPatch.always
  end
end
