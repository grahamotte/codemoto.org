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
          payload: { name: $constants.domain },
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
        .find { |x| x[:name] == $constants.domain }
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
        record[:name].end_with?($constants.domain) ? record[:name] : "#{record[:name]}.#{$constants.domain}",
        record[:type],
        record[:content],
      ].join(" :: ")
    end

    def cf_headers
      {
        Authorization: "Bearer #{$constants.cloudflare_token}",
        "Content-Type": "application/json",
      }
    end

    def desired
      [
        {
          type: "A",
          name: $constants.domain,
          content: $instance.ip,
          proxied: false,
          ttl: 1,
        },
        {
          type: "A",
          name: "www.#{$constants.domain}",
          content: $instance.ip,
          proxied: false,
          ttl: 1,
        },
        {
          type: "MX",
          name: $constants.domain,
          priority: 10,
          content: "in1-smtp.messagingengine.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "MX",
          name: $constants.domain,
          priority: 20,
          content: "in2-smtp.messagingengine.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "CNAME",
          name: "fm1._domainkey.#{$constants.domain}",
          content: "fm1.#{$constants.domain}.dkim.fmhosted.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "CNAME",
          name: "fm2._domainkey.#{$constants.domain}",
          content: "fm2.#{$constants.domain}.dkim.fmhosted.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "CNAME",
          name: "fm3._domainkey.#{$constants.domain}",
          content: "fm3.#{$constants.domain}.dkim.fmhosted.com",
          proxied: false,
          ttl: 1,
        },
        {
          type: "TXT",
          name: $constants.domain,
          content: "v=spf1 include:spf.messagingengine.com ?all",
          proxied: false,
          ttl: 1,
        },

      ]
    end
  end
end
