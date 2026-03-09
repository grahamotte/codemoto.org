class Notify
  class << self
    def call(message, user_id: ENV.fetch("SLACK_USER_ID"))
      url = ENV.fetch("SLACK_WEBHOOK_URL")

      raise ArgumentError, "SLACK_WEBHOOK_URL must be a slack.com URL" unless URI.parse(url).host&.end_with?("slack.com")

      conn = Faraday.new(url: url) do |f|
        f.response :raise_error
      end

      conn.post do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = { text: "<@#{user_id}> #{message}" }.to_json
      end
    end
  end
end
