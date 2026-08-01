require_relative "../test_helper"

class NginxPatchTest < Minitest::Test
  def test_nginx_config
    config = NginxPatch.send(:nginx_config)

    assert_includes config, "server_name example.com www.example.com hc.example.com jobs.example.com errors.example.com"
    assert_includes config, "root /var/www/example.com/frontend/dist/www"
    assert_includes config, "root /var/www/example.com/frontend/dist/hc"
    assert_includes config, "location /api/"
    assert_includes config, "server_name jobs.example.com"
    assert_includes config, "proxy_pass http://localhost:3000"
  end

  def test_always
    commands = []
    definition = nil
    Cmd.stubs(:ssh).with do |command, *|
      commands << command
      command != "which nginx" && !command.start_with?("systemctl show")
    end.returns("")
    Cmd.expects(:ssh).with("which nginx").returns("/usr/sbin/nginx")
    Cmd.expects(:ssh).with(regexp_matches(/\Asystemctl show/))
      .returns("LoadState=loaded\nActiveState=active\nFreezerState=running\n")
    Cmd.expects(:ssh_write).with do |path, content, sudo:|
      definition = content
      path == "/etc/nginx/nginx.conf" && sudo
    end

    NginxPatch.always

    assert_includes definition, "worker_processes 2"
    assert_includes commands, "sudo systemctl stop nginx.service"
    assert_includes commands, "sudo systemctl start nginx.service"
  end
end
