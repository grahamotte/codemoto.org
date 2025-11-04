class CertPatch < BasePatch
  class << self
    def needed?
      return true if cert_expires_on.blank?

      cert_expires_on - 14 < Date.today
    end

    def apply
      $instance.install_package("nginx")
      $instance.stop_service("nginx")
      Cmd.ssh_write("/etc/nginx/nginx.conf", default_nginx_conf, sudo: true)
      Cmd.ssh("sudo fuser -k 80/tcp || true")
      $instance.start_service("nginx")
      Cmd.ssh("sudo nginx -t")

      if $instance.not_installed?("certbot")
        Cmd.ssh("sudo snap install --classic certbot")
        Cmd.ssh("sudo ln -s /snap/bin/certbot /usr/bin/certbot")
      end

      Cmd.ssh("sudo rm -rf /etc/letsencrypt")
      Cmd.ssh("sudo certbot --nginx certonly --non-interactive --agree-tos -m cert@#{$constants.domain} -d #{$constants.domain} -d www.#{$constants.domain}")
      $instance.stop_service("nginx")
    end

    private

    def cert_expires_on
      Cmd
        .ssh("sudo cat /etc/letsencrypt/live/#{$constants.domain}/fullchain.pem | openssl x509 -noout -enddate")
        .split("=")
        .last
        .then { |x| Date.parse(x) }
    rescue StandardError => e
      puts e.message
      nil
    end

    def default_nginx_conf
      Req.call(
        url: "https://gist.githubusercontent.com/nishantmodak/d08aae033775cb1a0f8a/raw/ebea0ae66e0a0188009accae2acba88cc646ddcd/nginx.conf.default",
        content: :text
      )
    end
  end
end
