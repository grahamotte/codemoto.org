require_relative "../test_helper"

class CloudflareTest < Minitest::Test
  def test_create_zone
    Constants.stubs(:cloudflare_token).returns("token")
    Constants.stubs(:domain).returns("example.com")
    Req.expects(:call).with(
      method: :post,
      url: "https://api.cloudflare.com/client/v4/zones",
      headers: {
        Authorization: "Bearer token",
        "Content-Type": "application/json",
      },
      quiet: true,
      payload: { name: "example.com" },
    )

    Cloudflare.create_zone
  end

  def test_current_records_are_desired_regardless_of_order
    Cloudflare.stubs(:zone_id).returns("zone")
    Cloudflare.stubs(:current_dns_records).returns([
      { name: "www.example.com", type: "A", content: "1.2.3.4" },
      { name: "example.com", type: "MX", content: "mail.example.com" },
    ])
    Cloudflare.stubs(:desired_dns_records).returns([
      { name: "example.com", type: "MX", content: "mail.example.com" },
      { name: "www.example.com", type: "A", content: "1.2.3.4" },
    ])
    Constants.stubs(:domain).returns("example.com")

    assert Cloudflare.current_records_are_desired?
  end
end
