require_relative "../test_helper"

class ReqTest < Minitest::Test
  def test_json_request
    Req.stubs(:puts)
    stub_request(:post, "https://example.com/items?page=2")
      .with(body: '{"item":"value"}', headers: { "Content-Type" => "application/json" })
      .to_return(body: '{"item_id":3}')

    assert_equal(
      { item_id: 3 },
      DeployTestMethods::REQ_CALL.call(
        url: "https://example.com/items",
        method: :post,
        params: { page: 2 },
        payload: { item: "value" },
      ),
    )
  end

  def test_text_response
    Req.stubs(:puts)
    stub_request(:get, "https://example.com/text").to_return(body: "content")

    assert_equal(
      "content",
      DeployTestMethods::REQ_CALL.call(url: "https://example.com/text", content: :text),
    )
  end
end
