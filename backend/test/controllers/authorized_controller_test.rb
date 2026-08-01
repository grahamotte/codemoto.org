require "test_helper"

class TestAuthorizedController < AuthorizedController
  def index
    head :ok
  end
end

class AuthorizedControllerTest < ActionController::TestCase
  tests TestAuthorizedController

  def setup
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw { get "index" => "test_authorized#index" }
  end

  def test_authorizes_header_token
    @request.headers["Authorization"] = "Bearer valid"

    get :index

    assert_response :ok
  end

  def test_authorizes_session_token
    get :index, session: { jwt: "valid" }

    assert_response :ok
  end

  def test_rejects_invalid_token
    @request.headers["Authorization"] = "Bearer invalid"

    get :index

    assert_response :unauthorized
  end
end
