class Req
  class << self
    def call(
      url:,
      method: :get,
      headers: {},
      params: {},
      payload: {},
      quiet: true,
      content: :json,
      **_
    )
      headers = headers.merge("Content-Type" => "application/json")
      puts "#{method.upcase} #{url} #{params.present? || payload.present? ? params.merge(payload) : nil}".blue
      con = Faraday.new(url:, params:, headers:) do |f|
        f.use Faraday::Response::RaiseError
      end
      res = con.send(method) do |req|
        req.body = payload.to_json if payload.present?
      end

      case content
      when :json
        res = JSON.parse(res.body.blank? ? "{}" : res.body, symbolize_names: true)
      when :text
        res = res.body
      end

      puts res if !quiet && res.present?
      res
    end
  end
end
