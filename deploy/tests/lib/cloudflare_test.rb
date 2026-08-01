require_relative "../test_helper"

class CloudflareTest < Minitest::Test
  def setup
    Cloudflare.instance_variable_set(:@zone_id, nil)
  end

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

  def test_zone_id
    Constants.stubs(:cloudflare_token).returns("token")
    Constants.stubs(:domain).returns("example.com")
    Req.expects(:call).returns(result: [ { name: "other.com", id: "1" }, { name: "example.com", id: "2" } ])

    assert_equal "2", Cloudflare.zone_id
  end

  def test_zone_id_handles_request_failure
    Req.expects(:call).raises("failure")

    assert_nil Cloudflare.zone_id
  end

  def test_current_dns_records
    Cloudflare.stubs(:zone_id).returns("zone")
    Cloudflare.stubs(:headers).returns(headers = { Authorization: "token" })
    Req.expects(:call)
      .with(url: "https://api.cloudflare.com/client/v4/zones/zone/dns_records", headers:, quiet: true)
      .returns(result: [ { id: "record" } ])

    assert_equal [ { id: "record" } ], Cloudflare.current_dns_records
  end

  def test_current_dns_records_without_zone
    Cloudflare.stubs(:zone_id).returns(nil)

    assert_equal [], Cloudflare.current_dns_records
  end

  def test_mutates_dns_records
    Cloudflare.stubs(:zone_id).returns("zone")
    Cloudflare.stubs(:headers).returns(headers = { Authorization: "token" })
    record = { type: "A", name: "example.com", content: "1.2.3.4" }
    Req.expects(:call).with(
      method: :delete,
      url: "https://api.cloudflare.com/client/v4/zones/zone/dns_records/record",
      headers:,
      quiet: true,
    )
    Req.expects(:call).with(
      method: :post,
      url: "https://api.cloudflare.com/client/v4/zones/zone/dns_records",
      headers:,
      quiet: true,
      payload: record,
    )

    Cloudflare.delete_dns_record("record")
    Cloudflare.create_dns_record(record)
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

  def test_current_records_are_not_desired_without_zone
    Cloudflare.stubs(:zone_id).returns(nil)

    refute Cloudflare.current_records_are_desired?
  end

  def test_desired_dns_records
    Constants.stubs(:domain).returns("example.com")
    Subdomains.stubs(:domains).returns([ "example.com", "www.example.com" ])
    Instance.stubs(:ip).returns("1.2.3.4")

    records = Cloudflare.desired_dns_records

    assert_equal 8, records.length
    assert_equal(
      { type: "A", name: "www.example.com", content: "1.2.3.4", proxied: false, ttl: 1 },
      records[1],
    )
    assert_equal "example.com :: A :: 1.2.3.4", Cloudflare.fingerprint(records.first)
    assert_equal "www.example.com :: A :: 1.2.3.4", Cloudflare.fingerprint(records[1])
  end
end
