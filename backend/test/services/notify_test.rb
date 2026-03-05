require "test_helper"

class NotifyTest < ActiveSupport::TestCase
  def setup
    @url = "https://hooks.slack.com/services/abc123"
  end

  def test_posts_message_to_slack
    stub = stub_request(:post, @url).to_return(status: 200, body: "ok")

    with_env("SLACK_WEBHOOK_URL" => @url) do
      Notify.call("hello")
    end

    assert_requested stub
  end

  def test_raises_on_non_slack_url
    with_env("SLACK_WEBHOOK_URL" => "https://evil.com/webhook") do
      assert_raises(ArgumentError) { Notify.call("hello") }
    end
  end

  def test_raises_on_failed_request
    stub_request(:post, @url).to_return(status: 500, body: "error")

    with_env("SLACK_WEBHOOK_URL" => @url) do
      assert_raises(Faraday::ServerError) { Notify.call("hello") }
    end
  end

  private

  def with_env(vars)
    original = vars.keys.each_with_object({}) { |k, h| h[k] = ENV[k] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    original.each { |k, v| ENV[k] = v }
  end
end
