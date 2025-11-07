module Api
  class HealthCheckController < ApplicationController
    def index
      render json: {
        frontend_time: params[:frontend_time],
        backend_time: Time.current,
        database_time: ActiveRecord::Base.connection.execute("SELECT NOW()")[0]["now"].utc
      }
    end
  end
end
