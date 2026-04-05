class AppPatch < BasePatch
  class << self
    def always
      Cache.if_files_changed(File.expand_path("../frontend/bun.lock")) do
        Cmd.ssh("cd #{Constants.remote_root}/frontend; mise exec -- bun install")
      end

      Cache.if_files_changed(File.expand_path("../backend/Gemfile.lock")) do
        Cmd.ssh("cd #{Constants.remote_root}/backend; mise exec -- bundle install")
      end

      Instance.stop_service("api")
      Instance.stop_service("job")
      Cmd.ssh("sudo systemctl disable job.service || true")

      Cache.if_files_changed(Dir.glob(File.expand_path("../backend/db/migrate/*"))) do
        Cmd.ssh("cd #{Constants.remote_root}/backend; set -a; source ../.env; mise exec -- bin/rails db:migrate")
      end

      Cmd.ssh("rm -rf ~/tmp")

      Instance.write_service("api", api_service)
      Cmd.ssh("sudo systemctl start api.service")


      Cmd.ssh("cd #{Constants.remote_root}/frontend; set -a; source ../.env; mise exec -- bun vite build")
      # Cmd.local("cd #{Constants.local_root}; set -a; source .env.production; cd frontend; mise exec -- bun vite build")
      # Cmd.local("rsync -av -e \"ssh -i #{Constants.ssh_key_path}\" #{Constants.local_root}/frontend/dist/ #{Constants.deploy_user}@#{Instance.ip}:#{Constants.remote_root}/frontend/dist/")

      begin
        Req.call(method: :get, url: "https://#{Constants.domain}/api/noop/ping")
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
      User=#{Constants.deploy_user}
      Type=simple
      Environment=LD_PRELOAD=/lib/x86_64-linux-gnu/libjemalloc.so.2
      Environment=MALLOC_ARENA_MAX=2
      ExecStart=/usr/bin/bash -c 'cd #{Constants.remote_root}/backend && set -a && source ../.env && mise exec -- bin/rails server --port 3000'
      Restart=always

      [Install]
      WantedBy=default.target
    TEXT
  end
end
