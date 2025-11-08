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
      }
    end
  end
end
