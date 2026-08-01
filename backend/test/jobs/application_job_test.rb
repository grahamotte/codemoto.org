require "test_helper"

class TestApplicationJob < ApplicationJob
  schedule "every 5 minutes"

  def perform
    Current.job
  end
end

class ApplicationJobTest < ActiveSupport::TestCase
  def test_schedule_and_current_job
    job = TestApplicationJob.new

    assert_equal "every 5 minutes", TestApplicationJob.schedule_interval
    assert_same job, job.perform_now
  end

  def test_defaults
    assert_equal "default", TestApplicationJob.queue_name
    assert_equal 4.hours, ApplicationJob::TIMEOUT
  end
end
