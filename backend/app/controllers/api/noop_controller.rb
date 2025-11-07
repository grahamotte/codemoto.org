module Api
  class NoopController < AuthorizedController
    skip_before_action :authorize, only: [ :ping ]

    def ping
      render json: { message: "pong" }
    end

    def lock
      render json: { message: "load" }
    end
  end
end
