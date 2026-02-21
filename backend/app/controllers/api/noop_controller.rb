module Api
  class NoopController < AuthorizedController
    skip_before_action :authorize, only: [ :ping, :hc ]

    def ping
      render json: { message: "pong" }
    end

    def lock
      render json: { message: "load" }
    end

    def hc
      render json: {
        frontend_time: params[:frontend_time],
        backend_time: Time.current,
        database_time: ActiveRecord::Base.connection.execute("SELECT NOW()")[0]["now"].utc,
        hc_job_finished_at: latest_hc_job_finished_at,
      }
    end

    private

    def latest_hc_job_finished_at
      return if ActiveRecord::Base.connection.data_source_exists?("good_jobs").blank?

      GoodJob::Job.where(job_class: "HcJob").where.not(finished_at: nil).order(finished_at: :desc).pick(:finished_at)&.utc
    end
  end
end
