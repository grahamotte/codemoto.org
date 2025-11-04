Sentry.init do |config|
  config.dsn = ENV.fetch("SENTRY_DSN_BACKEND")
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.send_default_pii = true
  config.environment = ENV.fetch("ENV")
  config.release = `git rev-parse HEAD`.chomp.strip
  config.enable_logs = true
  config.enabled_patches = [ :logger ]
  config.traces_sample_rate = 1.0
end
