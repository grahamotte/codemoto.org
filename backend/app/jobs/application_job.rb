class ApplicationJob < ActiveJob::Base
  include GoodJob::ActiveJobExtensions::Concurrency

  TIMEOUT = 4.hour

  queue_as :default

  good_job_control_concurrency_with total_limit: 1, key: "all"

  class << self
    def schedule(interval) = @schedule = interval
    def schedule_interval = @schedule
  end

  around_perform do |job, block|
    Current._job = job
    Timeout.timeout(TIMEOUT) { block.call }
  end
end
