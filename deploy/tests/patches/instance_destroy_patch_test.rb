require_relative "../test_helper"

class InstanceDestroyPatchTest < Minitest::Test
  def test_always
    Req.expects(:call).with(has_entry(:url, "https://api.cloudflare.com/client/v4/zones"))
      .returns(result: [ { name: "example.com", id: "zone" } ])
    Req.expects(:call).with(has_entry(:url, "https://api.cloudflare.com/client/v4/zones/zone/dns_records"))
      .returns(result: [ { id: "one" }, { id: "two" } ])
    Req.expects(:call).with(has_entries(method: :delete, url: "https://api.cloudflare.com/client/v4/zones/zone/dns_records/one"))
    Req.expects(:call).with(has_entries(method: :delete, url: "https://api.cloudflare.com/client/v4/zones/zone/dns_records/two"))
    Req.expects(:call).with(has_entries(method: :get, url: "https://api.digitalocean.com/v2/droplets"))
      .returns(droplets: [ { name: "example.com", id: 3 } ])
    Req.expects(:call).with(has_entries(method: :delete, url: "https://api.digitalocean.com/v2/droplets/3"))

    InstanceDestroyPatch.always
  end
end
