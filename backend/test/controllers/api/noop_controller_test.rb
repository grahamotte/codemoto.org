require "test_helper"

module Api
  class NoopControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    def setup
      super
      @previous_queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :test
      clear_enqueued_jobs
      clear_performed_jobs
    end

    def teardown
      clear_enqueued_jobs
      clear_performed_jobs
      ActiveJob::Base.queue_adapter = @previous_queue_adapter
      super
    end

    def test_hc_enqueues_hc_job
      assert_enqueued_jobs 1, only: HcJob do
        get hc_api_noop_index_path, params: { frontend_time: "2026-05-14T20:23:19.326Z" }
      end

      assert_response :success
    end

    def test_hc_returns_latest_hc_job_execution_finished_at
      finished_at = Time.zone.parse("2026-05-14T20:23:19Z")
      GoodJob::Execution.create!(
        active_job_id: SecureRandom.uuid,
        job_class: "HcJob",
        queue_name: "default",
        serialized_params: {},
        scheduled_at: finished_at,
        finished_at:,
      )

      get hc_api_noop_index_path

      assert_response :success
      assert_equal finished_at.iso8601(3), response.parsed_body.fetch("hc_job_finished_at")
    end

    def test_error_raises
      error = assert_raises(RuntimeError) { post error_api_noop_index_path }

      assert_equal "Test backend error", error.message
    end
  end
end
