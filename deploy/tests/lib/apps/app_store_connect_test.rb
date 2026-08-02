require_relative "../../test_helper"

class AppsAppStoreConnectTest < Minitest::Test
  def test_generates_signed_token
    token = Apps::AppStoreConnect.new.send(:token)
    header, payload, signature = token.split(".")

    assert_equal "ES256", decode(header).fetch("alg")
    assert_equal ENV.fetch("APPLE_ISSUER_ID"), decode(payload).fetch("iss")
    assert signature.present?
  end

  def test_requires_processed_build
    client = Apps::AppStoreConnect.new
    target = Apps.targets.fetch(0)
    Req.expects(:call).times(5).returns(
      { data: [ { id: "app" } ] },
      { data: [ { id: "version", attributes: { versionString: "1.2.3" } } ] },
      { data: [ { id: "localization", attributes: { locale: "en-US" } } ] },
      {},
      { included: [] },
    )

    error = assert_raises(RuntimeError) { client.submit(target) }

    assert_includes error.message, "still processing"
  end

  def test_prepares_codemoto_without_submitting
    target = Apps.targets.fetch(0).merge(bundleIdentifier: "com.grahamotte.codemoto")
    expect_request(:get, "/v1/apps").returns(data: [ { id: "app" } ])
    expect_request(:get, "/v1/apps/app/appStoreVersions").returns(
      data: [ { id: "version", attributes: { versionString: "1.2.3" } } ],
    )
    expect_request(:get, "/v1/appStoreVersions/version/appStoreVersionLocalizations").returns(
      data: [ { id: "localization", attributes: { locale: "en-US" } } ],
    )
    expect_request(:patch, "/v1/appStoreVersionLocalizations/localization").returns({})
    expect_request(:get, "/v1/preReleaseVersions").returns(
      included: [ { id: "build", attributes: { processingState: "VALID" } } ],
    )
    expect_request(:patch, "/v1/appStoreVersions/version/relationships/build").returns({})

    output, = capture_io do
      assert_equal :prepared, Apps::AppStoreConnect.new.submit(target)
    end

    assert_includes output, "Skipping actual submission"
  end

  private

  def decode(value)
    padding = "=" * ((4 - value.length % 4) % 4)
    JSON.parse("#{value}#{padding}".tr("-_", "+/").unpack1("m0"))
  end

  def expect_request(method, path)
    Req.expects(:call).with do |request|
      request[:method] == method && request[:url] == "#{Apps::AppStoreConnect::BASE_URL}#{path}"
    end
  end
end
