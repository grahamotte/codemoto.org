class DnsPatch < BasePatch
  class << self
    def needed?
      return true if zone_id.blank?
      current.map { |x| fingerprint(x) }.sort != desired.map { |x| fingerprint(x) }.sort
    end

    def apply
      if zone_id.blank?
        Req.call(
          method: :post,
          url: "https://api.cloudflare.com/client/v4/zones",
          headers: cf_headers,
          quiet: true,
          payload: { name: Constants.domain },
        )

        sleep 5
      end

      current.each do |record|
        Req.call(
          method: :delete,
          url: "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records/#{record[:id]}",
          headers: cf_headers,
          quiet: true,
        )
      end

      desired.each do |record|
        Req.call(
          method: :post,
          url: "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records",
          headers: cf_headers,
          quiet: true,
          payload: record,
        )
      end
    end

    private

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

    def current
      Req
        .call(
          url: "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records",
          headers: cf_headers,
          quiet: true,
        )
        .fetch(:result)
    end

    def fingerprint(record)
      [
        record[:name].end_with?(Constants.domain) ? record[:name] : "#{record[:name]}.#{Constants.domain}",
        record[:type],
        record[:content],
      ].join(" :: ")
    end

    def cf_headers
      {
        Authorization: "Bearer #{Constants.cloudflare_token}",
        "Content-Type": "application/json",
      }
    end

    def desired
      [
        {
          type: "A",
          name: Constants.domain,
          content: Instance.ip,
          proxied: false,
          ttl: 1,
        },
        {
          type: "A",
          name: "www.#{Constants.domain}",
          content: Instance.ip,
          proxied: false,
          ttl: 1,
        },
        {
          type: "MX",
          name: Constants.domain,
          priority: 10,
          content: "in1-smtp.messagingengine.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "MX",
          name: Constants.domain,
          priority: 20,
          content: "in2-smtp.messagingengine.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "CNAME",
          name: "fm1._domainkey.#{Constants.domain}",
          content: "fm1.#{Constants.domain}.dkim.fmhosted.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "CNAME",
          name: "fm2._domainkey.#{Constants.domain}",
          content: "fm2.#{Constants.domain}.dkim.fmhosted.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "CNAME",
          name: "fm3._domainkey.#{Constants.domain}",
          content: "fm3.#{Constants.domain}.dkim.fmhosted.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "TXT",
          name: Constants.domain,
          content: "v=spf1 include:spf.messagingengine.com ?all",
          proxied: false,
          ttl: 1,
        },

      ]
    end
  end
end
