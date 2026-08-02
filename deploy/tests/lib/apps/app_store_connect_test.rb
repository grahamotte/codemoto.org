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
    Req.expects(:call).times(10).returns(
      { data: [ { id: "app" } ] },
      { data: [ { id: "version", attributes: { versionString: "1.2.3" } } ] },
      {},
      { data: [ { id: "localization", attributes: { locale: "en-US" } } ] },
      {},
      screenshot_sets,
      screenshots,
      { data: nil },
      {},
      { included: [] },
    )

    error = assert_raises(RuntimeError) { client.submit(target) }

    assert_includes error.message, "still processing"
  end

  def test_prepares_codemoto_without_submitting
    target = Apps.targets.fetch(0).merge(bundleIdentifier: "com.grahamotte.codemoto")
    requests = []
    Req.expects(:call).times(14).with { |request| requests << request }.returns(
      { data: [ { id: "app" } ] },
      { data: [ { id: "version", attributes: { versionString: "1.2.3" } } ] },
      {},
      { data: [ { id: "localization", attributes: { locale: "en-US" } } ] },
      {},
      screenshot_sets,
      screenshots,
      { data: nil },
      {},
      { included: [ { id: "build", attributes: { processingState: "VALID" } } ] },
      {},
      { data: [ { id: "submission" } ] },
      { data: [] },
      {},
    )

    output, = capture_io do
      assert_equal :prepared, Apps::AppStoreConnect.new.submit(target)
    end

    assert_includes output, "Skipping actual submission"
    assert_request(requests, :patch, "/v1/appStoreVersions/version") do |attributes|
      assert_equal "1.2.3", attributes.fetch(:versionString)
      assert_equal "2026 Example", attributes.fetch(:copyright)
      assert_equal "AFTER_APPROVAL", attributes.fetch(:releaseType)
    end
    assert_request(requests, :patch, "/v1/appStoreVersionLocalizations/localization") do |attributes|
      assert_equal "Promotional text", attributes.fetch(:promotionalText)
      assert_equal "https://example.com/support", attributes.fetch(:supportUrl)
      refute attributes.key?(:whatsNew)
    end
    assert_request(requests, :post, "/v1/appStoreReviewDetails") do |attributes|
      assert_equal "login", attributes.fetch(:demoAccountName)
      assert_equal "First", attributes.fetch(:contactFirstName)
      assert_equal "Notes", attributes.fetch(:notes)
    end
    assert_request(requests, :post, "/v1/reviewSubmissionItems")
    refute requests.any? { |request|
      request[:payload].dig(:data, :attributes, :submitted) == true
    }
  end

  def test_creates_version_with_release_settings
    target = Apps.targets.fetch(0)
    expect_request(:get, "/v1/apps/app/appStoreVersions").returns(data: [])
    request = nil
    Req.expects(:call).with do |item|
      request = item
      item[:method] == :post && item[:url] == "#{Apps::AppStoreConnect::BASE_URL}/v1/appStoreVersions"
    end.returns(data: { id: "version" })

    version = Apps::AppStoreConnect.new.send(:store_version, "app", target)

    assert_equal "version", version.fetch(:id)
    assert_equal "1.2.3", request.dig(:payload, :data, :attributes, :versionString)
    assert_equal "2026 Example", request.dig(:payload, :data, :attributes, :copyright)
    assert_equal "AFTER_APPROVAL", request.dig(:payload, :data, :attributes, :releaseType)
  end

  def test_reuses_an_editable_version
    target = Apps.targets.fetch(0)
    expect_request(:get, "/v1/apps/app/appStoreVersions").returns(
      data: [
        {
          id: "draft",
          attributes: {
            appVersionState: "PREPARE_FOR_SUBMISSION",
            createdDate: "2026-01-01",
            versionString: "1.2.2",
          },
        },
      ],
    )

    version = Apps::AppStoreConnect.new.send(:store_version, "app", target)

    assert_equal "draft", version.fetch(:id)
  end

  def test_sends_whats_new_for_subsequent_versions
    client = Apps::AppStoreConnect.new
    target = Apps.targets.fetch(0)
    expect_request(:get, "/v1/apps/app/appStoreVersions").returns(
      data: [
        { id: "version", attributes: { versionString: "1.2.3" } },
        { id: "previous", attributes: { versionString: "1.2.2" } },
      ],
    )
    expect_request(:get, "/v1/appStoreVersions/version/appStoreVersionLocalizations").returns(
      data: [ { id: "localization", attributes: { locale: "en-US" } } ],
    )
    request = nil
    Req.expects(:call).with do |item|
      request = item
      item[:method] == :patch &&
        item[:url] == "#{Apps::AppStoreConnect::BASE_URL}/v1/appStoreVersionLocalizations/localization"
    end.returns({})

    version = client.send(:store_version, "app", target)
    client.send(:update_localization, version.fetch(:id))

    assert_equal "Changes", request.dig(:payload, :data, :attributes, :whatsNew)
  end

  def test_omits_demo_credentials_when_not_required
    Apps.config[:demoAccountRequired] = false

    attributes = Apps::AppStoreConnect.new.send(:review_attributes)

    assert_equal false, attributes.fetch(:demoAccountRequired)
    refute attributes.key?(:demoAccountName)
    refute attributes.key?(:demoAccountPassword)
  end

  def test_uploads_missing_screenshot
    client = Apps::AppStoreConnect.new
    target = Apps.targets.fetch(0)
    screenshot = target.fetch(:screenshots).fetch(0)
    path = Apps.screenshot_path(screenshot)
    checksum = Digest::MD5.file(path).hexdigest
    expect_request(:get, "/v1/appStoreVersionLocalizations/localization/appScreenshotSets").returns(data: [])
    expect_request(:post, "/v1/appScreenshotSets").returns(data: { id: "set" })
    expect_request(:get, "/v1/appScreenshotSets/set/appScreenshots").returns(data: [])
    expect_request(:post, "/v1/appScreenshots").returns(
      data: {
        id: "screenshot",
        attributes: {
          uploadOperations: [
            {
              length: File.size(path),
              method: "PUT",
              offset: 0,
              requestHeaders: [ { name: "Content-Type", value: "image/jpeg" } ],
              url: "https://upload.example.com/screenshot",
            },
          ],
        },
      },
    )
    Req.expects(:call).with do |request|
      request[:url] == "https://upload.example.com/screenshot" &&
        request[:method] == :put &&
        request[:headers] == { "Content-Type" => "image/jpeg" } &&
        request[:body] == File.binread(path)
    end.returns("")
    Req.expects(:call).with do |request|
      request[:method] == :patch &&
        request[:url] == "#{Apps::AppStoreConnect::BASE_URL}/v1/appScreenshots/screenshot" &&
        request.dig(:payload, :data, :attributes, :sourceFileChecksum) == checksum
    end.returns({})
    expect_request(:get, "/v1/appScreenshots/screenshot").returns(
      data: { attributes: { assetDeliveryState: { state: "COMPLETE" } } },
    )

    client.send(:update_screenshots, "localization", target)
  end

  def test_waits_for_screenshot_processing
    waits = 0
    client = Apps::AppStoreConnect.new(wait: -> { waits += 1 })
    Req.expects(:call).twice.with do |request|
      request[:method] == :get &&
        request[:url] == "#{Apps::AppStoreConnect::BASE_URL}/v1/appScreenshots/screenshot"
    end.returns(
      { data: { attributes: { assetDeliveryState: { state: "UPLOAD_COMPLETE" } } } },
      { data: { attributes: { assetDeliveryState: { state: "COMPLETE" } } } },
    )

    client.send(:wait_for_screenshots, [ "screenshot" ])

    assert_equal 1, waits
  end

  def test_rejects_failed_screenshot_processing
    client = Apps::AppStoreConnect.new
    expect_request(:get, "/v1/appScreenshots/screenshot").returns(
      data: { attributes: { assetDeliveryState: { state: "FAILED" } } },
    )

    error = assert_raises(RuntimeError) do
      client.send(:wait_for_screenshots, [ "screenshot" ])
    end

    assert_includes error.message, "failed processing"
  end

  def test_times_out_screenshot_processing
    times = [ 0, 1_200 ]
    client = Apps::AppStoreConnect.new(clock: -> { times.shift })
    expect_request(:get, "/v1/appScreenshots/screenshot").returns(
      data: { attributes: { assetDeliveryState: { state: "UPLOAD_COMPLETE" } } },
    )

    error = assert_raises(RuntimeError) do
      client.send(:wait_for_screenshots, [ "screenshot" ])
    end

    assert_includes error.message, "Timed out"
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

  def assert_request(requests, method, path)
    request = requests.find do |item|
      item[:method] == method && item[:url] == "#{Apps::AppStoreConnect::BASE_URL}#{path}"
    end
    assert request, "Missing #{method.upcase} #{path}"
    yield request.dig(:payload, :data, :attributes) if block_given?
  end

  def screenshot_sets
    {
      data: [ { id: "set", attributes: { screenshotDisplayType: "APP_IPHONE_65" } } ],
    }
  end

  def screenshots
    screenshot = Apps.targets.fetch(0).fetch(:screenshots).fetch(0)
    path = Apps.screenshot_path(screenshot)
    {
      data: [
        {
          id: "screenshot",
          attributes: {
            assetDeliveryState: { state: "COMPLETE" },
            fileName: File.basename(path),
            sourceFileChecksum: Digest::MD5.file(path).hexdigest,
          },
        },
      ],
    }
  end
end
