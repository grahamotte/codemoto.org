class AuthorizedController < ApplicationController
  before_action :authorize

  private

  def authorize
    token = request.headers["Authorization"]&.split&.last || session[:jwt]

    head :unauthorized unless Token.verify(token)
  end
end
