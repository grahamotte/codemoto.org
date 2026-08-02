module Apps
  class AppStoreConnect
    BASE_URL = "https://api.appstoreconnect.apple.com"

    def submit(target)
      apps = get("/v1/apps", params: { "filter[bundleId]" => target.fetch(:bundleIdentifier) }).fetch(:data)
      raise "Expected one App Store app for #{target.fetch(:bundleIdentifier)}" unless apps.length == 1

      app = apps.fetch(0)
      version = store_version(app.fetch(:id), target)
      update_localization(version.fetch(:id))
      build = processed_build(app.fetch(:id), target)
      raise "Build #{Apps.build} is still processing; rerun publish later" if build.blank?

      patch(
        "/v1/appStoreVersions/#{version.fetch(:id)}/relationships/build",
        data: { type: "builds", id: build.fetch(:id) },
      )
      if target.fetch(:bundleIdentifier).include?("codemoto")
        puts "Skipping actual submission for #{target.fetch(:bundleIdentifier)}."
        return :prepared
      end

      submit_version(app.fetch(:id), version.fetch(:id), target.fetch(:platform))
      :submitted
    end

    private

    def store_version(app_id, target)
      versions = get(
        "/v1/apps/#{app_id}/appStoreVersions",
        params: { "filter[platform]" => target.fetch(:platform), "limit" => 200 },
      ).fetch(:data)
      versions.find { |item| item.dig(:attributes, :versionString) == Apps.version } || create_version(app_id, target)
    end

    def create_version(app_id, target)
      post(
        "/v1/appStoreVersions",
        data: {
          type: "appStoreVersions",
          attributes: {
            platform: target.fetch(:platform),
            versionString: Apps.version,
          },
          relationships: {
            app: { data: { type: "apps", id: app_id } },
          },
        },
      ).fetch(:data)
    end

    def update_localization(version_id)
      localizations = get("/v1/appStoreVersions/#{version_id}/appStoreVersionLocalizations").fetch(:data)
      localization = localizations.find { |item| item.dig(:attributes, :locale) == Apps.config.fetch(:primaryLocale) }
      attributes = {
        description: Apps.release.fetch(:description),
        keywords: Apps.release.fetch(:keywords),
        whatsNew: Apps.release.fetch(:whatsNew),
      }

      if localization.present?
        patch(
          "/v1/appStoreVersionLocalizations/#{localization.fetch(:id)}",
          data: {
            type: "appStoreVersionLocalizations",
            id: localization.fetch(:id),
            attributes:,
          },
        )
      else
        post(
          "/v1/appStoreVersionLocalizations",
          data: {
            type: "appStoreVersionLocalizations",
            attributes: attributes.merge(locale: Apps.config.fetch(:primaryLocale)),
            relationships: {
              appStoreVersion: { data: { type: "appStoreVersions", id: version_id } },
            },
          },
        )
      end
    end

    def processed_build(app_id, target)
      response = get(
        "/v1/preReleaseVersions",
        params: {
          "filter[app]" => app_id,
          "filter[builds.version]" => Apps.build,
          "filter[platform]" => target.fetch(:platform),
          "filter[version]" => Apps.version,
          "include" => "builds",
          "limit" => 1,
          "limit[builds]" => 50,
        },
      )
      response.fetch(:included, []).find { |item| item.dig(:attributes, :processingState) == "VALID" }
    end

    def submit_version(app_id, version_id, platform)
      submissions = get(
        "/v1/apps/#{app_id}/reviewSubmissions",
        params: { "filter[platform]" => platform, "filter[state]" => "READY_FOR_REVIEW", "limit" => 200 },
      ).fetch(:data)
      submission = submissions.first || post(
        "/v1/reviewSubmissions",
        data: {
          type: "reviewSubmissions",
          relationships: { app: { data: { type: "apps", id: app_id } } },
        },
      ).fetch(:data)

      post(
        "/v1/reviewSubmissionItems",
        data: {
          type: "reviewSubmissionItems",
          relationships: {
            appStoreVersion: { data: { type: "appStoreVersions", id: version_id } },
            reviewSubmission: { data: { type: "reviewSubmissions", id: submission.fetch(:id) } },
          },
        },
      )
      patch(
        "/v1/reviewSubmissions/#{submission.fetch(:id)}",
        data: {
          type: "reviewSubmissions",
          id: submission.fetch(:id),
          attributes: { submitted: true },
        },
      )
    end

    def get(path, params: {})
      request(path, params:)
    end

    def post(path, data:)
      request(path, method: :post, payload: { data: })
    end

    def patch(path, data:)
      request(path, method: :patch, payload: { data: })
    end

    def request(path, method: :get, params: {}, payload: {})
      Req.call(
        url: "#{BASE_URL}#{path}",
        method:,
        params:,
        payload:,
        headers: { "Authorization" => "Bearer #{token}" },
      )
    end

    def token
      now = Time.now.to_i
      header = encode(alg: "ES256", kid: ENV.fetch("APPLE_KEY_ID"), typ: "JWT")
      payload = encode(
        iss: ENV.fetch("APPLE_ISSUER_ID"),
        iat: now,
        exp: now + 1_200,
        aud: "appstoreconnect-v1",
      )
      signature = Apps.private_key.sign(OpenSSL::Digest::SHA256.new, "#{header}.#{payload}")
      integers = OpenSSL::ASN1.decode(signature).value
      raw_signature = integers.map { |integer| integer.value.to_s(2).rjust(32, "\0") }.join
      "#{header}.#{payload}.#{base64url(raw_signature)}"
    end

    def encode(value)
      base64url(JSON.generate(value))
    end

    def base64url(value)
      [ value ].pack("m0").tr("+/", "-_").delete("=")
    end
  end
end
