class AppPatch < BasePatch
  class << self
    def always
      Cache.if_files_changed(File.expand_path("../frontend/bun.lock")) do
        Cmd.ssh("cd #{$constants.remote_root}/frontend; mise exec -- bun install")
      end

      Cache.if_files_changed(File.expand_path("../backend/Gemfile.lock")) do
        Cmd.ssh("cd #{$constants.remote_root}/backend; mise exec -- bundle install")
      end

      $instance.stop_service("api")
      $instance.stop_service("job")

      Cache.if_files_changed(Dir.glob(File.expand_path("../backend/db/migrate/*"))) do
        Cmd.ssh("cd #{$constants.remote_root}/backend; set -a; source ../.env; mise exec -- bin/rails db:migrate")
      end

      Cmd.ssh("cd #{$constants.remote_root}/backend; set -a; source ../.env; mise exec -- bin/rails runner 'DeployResetter.call'")
      Cmd.ssh("rm -rf ~/tmp")

      $instance.write_service("api", api_service)
      $instance.write_service("job", job_service)
      Cmd.ssh("sudo systemctl start api.service")
      Cmd.ssh("sudo systemctl start job.service")


      Cmd.ssh("cd #{$constants.remote_root}/frontend; set -a; source ../.env; mise exec -- bun vite build")
      # Cmd.local("cd #{$constants.local_root}; set -a; source .env.production; cd frontend; mise exec -- bun vite build")
      # Cmd.local("rsync -av -e \"ssh -i #{$constants.ssh_key_path}\" #{$constants.local_root}/frontend/dist/ #{$constants.deploy_user}@#{$instance.ip}:#{$constants.remote_root}/frontend/dist/")

      begin
        Req.call(method: :post, url: "https://#{$constants.domain}/api/noop/ping")
      rescue StandardError => e
        puts "#{e.message} - waiting for rails to start..."
        sleep 1
        retry
      end
    end

    private

    def api_service = <<~TEXT
      [Unit]
      Description=Api
      Wants=network-online-target
      After=network-online-target

      [Service]
      User=#{$constants.deploy_user}
      Type=simple
      ExecStart=/usr/bin/bash -c 'cd #{$constants.remote_root}/backend && set -a && source ../.env && mise exec -- bin/rails server --port 3000'
      Restart=always

      [Install]
      WantedBy=default.target
    TEXT

    def job_service = <<~TEXT
      [Unit]
      Description=Job
      Wants=network-online-target
      After=network-online-target

      [Service]
      User=#{$constants.deploy_user}
      Type=simple
      ExecStart=/usr/bin/bash -c 'cd #{$constants.remote_root}/backend && set -a && source ../.env && mise exec -- bin/jobs'
      Restart=always

      [Install]
      WantedBy=default.target
    TEXT
  end
end
