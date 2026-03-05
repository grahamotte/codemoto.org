class Notify
  class << self
    def call(message)
      url = ENV.fetch("SLACK_WEBHOOK_URL")

      raise ArgumentError, "SLACK_WEBHOOK_URL must be a slack.com URL" unless URI.parse(url).host&.end_with?("slack.com")

      conn = Faraday.new(url: url) do |f|
        f.response :raise_error
      end

      conn.post do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = { text: message }.to_json
      end
    end
  end
end
