require_relative "../../test_helper"

class AppsSubmitPatchTest < Minitest::Test
  def test_submits_targets_once
    stub_submission_requests

    Apps::SubmitPatch.apply
    Apps::SubmitPatch.apply

    refute Apps::SubmitPatch.needed?
    assert_equal "submitted", Cache.get("apps/1.2.3/ios/submission")
  end

  private

  def stub_submission_requests
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
    expect_request(:get, "/v1/apps/app/reviewSubmissions").returns(data: [ { id: "submission" } ])
    expect_request(:post, "/v1/reviewSubmissionItems").returns({})
    expect_request(:patch, "/v1/reviewSubmissions/submission").returns({})
  end

  def expect_request(method, path)
    Req.expects(:call).with do |request|
      request[:method] == method && request[:url] == "#{Apps::AppStoreConnect::BASE_URL}#{path}"
    end
  end
end
