require "test_helper"

class DashboardSubdomainsTest < ActionDispatch::IntegrationTest
  test "serves jobs from its subdomain" do
    host! "jobs.codemoto.localhost"
    get "/"

    assert_response :unauthorized
  end

  test "serves errors from its subdomain" do
    host! "errors.codemoto.localhost"
    get "/"

    assert_response :success
  end
end
