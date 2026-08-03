require_relative "../../test_helper"

class AppsSubmitPatchTest < Minitest::Test
  def test_updates_metadata_every_time_and_submits_once
    stub_submission_requests(finalize: true)
    stub_submission_requests(finalize: false)

    Apps::SubmitPatch.apply
    Apps::SubmitPatch.apply

    assert Apps::SubmitPatch.needed?
    assert_equal "submitted", Cache.get("apps/1.2.3/ios/submission")
  end

  private

  def stub_submission_requests(finalize:)
    expect_request(:get, "/v1/apps").returns(data: [ { id: "app" } ])
    expect_request(:get, "/v1/apps/app/appStoreVersions").returns(
      data: [ { id: "version", attributes: { versionString: "1.2.3" } } ],
    )
    expect_request(:patch, "/v1/appStoreVersions/version").returns({})
    expect_request(:get, "/v1/appStoreVersions/version/appStoreVersionLocalizations").returns(
      data: [ { id: "localization", attributes: { locale: "en-US" } } ],
    )
    expect_request(:patch, "/v1/appStoreVersionLocalizations/localization").returns({})
    expect_request(:get, "/v1/appStoreVersionLocalizations/localization/appScreenshotSets").returns(
      data: [ { id: "set", attributes: { screenshotDisplayType: "APP_IPHONE_65" } } ],
    )
    screenshot = Apps.targets.fetch(0).fetch(:screenshots).fetch(0)
    path = Apps.screenshot_path(screenshot)
    expect_request(:get, "/v1/appScreenshotSets/set/appScreenshots").returns(
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
    )
    expect_request(:get, "/v1/appStoreVersions/version/relationships/appStoreReviewDetail").returns(
      data: { id: "review" },
    )
    expect_request(:patch, "/v1/appStoreReviewDetails/review").returns({})
    expect_request(:get, "/v1/preReleaseVersions").returns(
      included: [ { id: "build", attributes: { processingState: "VALID" } } ],
    )
    expect_request(:patch, "/v1/appStoreVersions/version/relationships/build").returns({})
    return unless finalize

    expect_request(:get, "/v1/apps/app/reviewSubmissions").returns(
      data: [ { id: "submission", attributes: { state: "READY_FOR_REVIEW" } } ],
    )
    expect_request(:get, "/v1/reviewSubmissions/submission/items").returns(data: [])
    expect_request(:post, "/v1/reviewSubmissionItems").returns({})
    expect_request(:patch, "/v1/reviewSubmissions/submission").returns({})
  end

  def expect_request(method, path)
    Req.expects(:call).with do |request|
      request[:method] == method && request[:url] == "#{Apps::AppStoreConnect::BASE_URL}#{path}"
    end
  end
end
