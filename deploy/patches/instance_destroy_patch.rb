class InstanceDestroyPatch < BasePatch
  class << self
    def always
      clear_dns_records
      Instance.destroy
    end

    private

    def clear_dns_records
      return if zone_id.blank?

      current_dns_records.each do |record|
        Req.call(
          method: :delete,
          url: "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records/#{record[:id]}",
          headers: cf_headers,
          quiet: true,
        )
      end
    end

    def zone_id
      @zone_id ||= Req
        .call(
          url: "https://api.cloudflare.com/client/v4/zones",
          headers: cf_headers,
          quiet: true,
        )
        .dig(:result)
        .find { |x| x[:name] == Constants.domain }
        .dig(:id)
    rescue StandardError => e
      puts e.message
      nil
    end

    def current_dns_records
      return [] if zone_id.blank?

      Req
        .call(
          url: "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records",
          headers: cf_headers,
          quiet: true,
        )
        .fetch(:result)
    rescue StandardError => e
      puts e.message
      []
    end

    def cf_headers
      {
        Authorization: "Bearer #{Constants.cloudflare_token}",
        "Content-Type": "application/json",
      }
    end
  end
end
