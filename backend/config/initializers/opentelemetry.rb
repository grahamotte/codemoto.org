return if Rails.env.test?
return if ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].blank?

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry-logs-sdk"
require "opentelemetry/exporter/otlp_logs"
require "opentelemetry/instrumentation/logger"
require "opentelemetry/instrumentation/rack"
require "opentelemetry/instrumentation/rails"
require "opentelemetry/instrumentation/action_pack"
require "opentelemetry/instrumentation/active_record"

resource = OpenTelemetry::SDK::Resources::Resource.create(
  {
    "service.name" => ENV.fetch("OTEL_SERVICE_NAME", "unknown"),
    "deployment.environment" => Rails.env.to_s,
    "deployment.environment.name" => Rails.env.to_s,
  },
)

logs_exporter = OpenTelemetry::Exporter::OTLP::Logs::LogsExporter.new
logs_processor = OpenTelemetry::SDK::Logs::Export::BatchLogRecordProcessor.new(logs_exporter)
logs_provider = OpenTelemetry::SDK::Logs::LoggerProvider.new(resource: resource)
logs_provider.add_log_record_processor(logs_processor)
OpenTelemetry.logger_provider = logs_provider

OpenTelemetry::SDK.configure do |config|
  config.resource = resource
  config.use "OpenTelemetry::Instrumentation::Logger"
  config.use "OpenTelemetry::Instrumentation::Rack"
  config.use "OpenTelemetry::Instrumentation::Rails"
  config.use "OpenTelemetry::Instrumentation::ActionPack"
  config.use "OpenTelemetry::Instrumentation::ActiveRecord"
end
