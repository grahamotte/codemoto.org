class CertPatch < BasePatch
  class << self
    def needed?
      return true if cert_expires_on.blank?
      return true if certificate_domains.sort != Subdomains.domains.sort

      cert_expires_on - 14 < Date.today
    end

    def apply
      Instance.install_package("nginx")
      Instance.stop_service("nginx")
      Cmd.ssh_write("/etc/nginx/nginx.conf", default_nginx_conf, sudo: true)
      Cmd.ssh("sudo fuser -k 80/tcp || true")
      Instance.start_service("nginx")
      Cmd.ssh("sudo nginx -t")

      if Instance.not_installed?("certbot")
        Cmd.ssh("sudo snap install --classic certbot")
        Cmd.ssh("sudo ln -s /snap/bin/certbot /usr/bin/certbot")
      end

      domains = Subdomains.domains.map { |x| "-d #{x}" }.join(" ")
      Cmd.ssh("sudo certbot --nginx certonly --non-interactive --agree-tos --cert-name #{Constants.domain} -m cert@#{Constants.domain} #{domains}")
      Instance.stop_service("nginx")
    end

    private

    def cert_expires_on
      certificate
        .lines
        .first
        .split("=", 2)
        .last
        .then { |x| Date.parse(x) }
    rescue StandardError => e
      puts e.message
      nil
    end

    def certificate_domains
      certificate.scan(/DNS:([^,\s]+)/).flatten
    end

    def certificate
      @certificate ||= Cmd.ssh("sudo cat /etc/letsencrypt/live/#{Constants.domain}/fullchain.pem | openssl x509 -noout -enddate -ext subjectAltName")
    end

    def default_nginx_conf
      Req.call(
        url: "https://gist.githubusercontent.com/nishantmodak/d08aae033775cb1a0f8a/raw/ebea0ae66e0a0188009accae2acba88cc646ddcd/nginx.conf.default",
        content: :text
      )
    end
  end
end
