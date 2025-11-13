class ApplicationJob < ActiveJob::Base
  TIMEOUT = 4.hour

  queue_as :default

  limits_concurrency to: 1, key: "all", duration: TIMEOUT + 1.hour

  class << self
    def schedule(interval) = @schedule = interval
    def schedule_interval = @schedule
  end

  around_perform do |job, block|
    Current._job = job
    Timeout.timeout(TIMEOUT) { block.call }
  end
end
