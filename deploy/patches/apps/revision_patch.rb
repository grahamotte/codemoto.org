module Apps
  class RevisionPatch < BasePatch
    class << self
      def needed?
        repositories.any? do |repository|
          Apps.targets.any? { |target| Cache.get(cache_key(repository, target)).blank? }
        end
      end

      def apply
        Apps.targets.each do |target|
          raise "Missing archive for #{target.fetch(:name)}" unless File.directory?(Apps.archive_path(target))

          package(target)
          repositories.each { |repository| upload(repository, target) }
        end
      end

      private

      def repositories = Apps.revision_repositories

      def package(target)
        return if File.file?(Apps.revision_path(target))

        FileUtils.rm_rf(Apps.revision_export_path(target))
        FileUtils.mkdir_p(Apps.revision_export_path(target))
        FileUtils.mkdir_p(File.dirname(Apps.revision_path(target)))
        export(target)
        product = revision_product(target)
        if target.fetch(:platform) == "MAC_OS"
          Cmd.local(Shellwords.join([ "codesign", "--verify", "--deep", "--strict", product ]))
          Cmd.local(Shellwords.join([ "ditto", "-c", "-k", "--keepParent", product, Apps.revision_path(target) ]))
          notarize(product, target)
        else
          FileUtils.cp(product, Apps.revision_path(target))
        end
      end

      def notarize(product, target)
        result = Cmd.local(Shellwords.join([
          "xcrun",
          "notarytool",
          "submit",
          Apps.revision_path(target),
          "--key",
          Apps.private_key_path,
          "--key-id",
          ENV.fetch("APPLE_KEY_ID"),
          "--issuer",
          ENV.fetch("APPLE_ISSUER_ID"),
          "--wait",
        ]))
        raise "Notarization failed for #{target.fetch(:name)}" unless result.include?("status: Accepted")
        Cmd.local(Shellwords.join([ "xcrun", "stapler", "staple", product ]))
        Cmd.local(Shellwords.join([ "spctl", "--assess", "--type", "execute", product ]))
        FileUtils.rm_f(Apps.revision_path(target))
        Cmd.local(Shellwords.join([ "ditto", "-c", "-k", "--keepParent", product, Apps.revision_path(target) ]))
      end

      def export(target)
        name, prefix = target.fetch(:platform) == "MAC_OS" ? [ "Developer ID Application", "APPLE_DEVELOPER_ID" ] : [ "Apple Distribution", "APPLE_DISTRIBUTION" ]
        Apps.with_signing_certificate(name, prefix) do |keychain|
          export_archive(target, keychain)
          next unless target.fetch(:platform) == "MAC_OS"

          Cmd.local(Shellwords.join([
            "codesign",
            "--force",
            "--deep",
            "--options",
            "runtime",
            "--timestamp",
            "--preserve-metadata=entitlements,requirements",
            "--sign",
            name,
            "--keychain",
            keychain,
            revision_product(target),
          ]))
        end
      end

      def export_archive(target, keychain)
        Tempfile.create([ "revision-export", ".plist" ]) do |file|
          file.write(export_options(target))
          file.close
          Cmd.local(Shellwords.join([
            "xcodebuild",
            "-exportArchive",
            "-archivePath",
            Apps.archive_path(target),
            "-exportPath",
            Apps.revision_export_path(target),
            "-exportOptionsPlist",
            file.path,
            "-allowProvisioningUpdates",
            "OTHER_CODE_SIGN_FLAGS=--keychain #{keychain}",
            *Apps.authentication_arguments,
          ]))
        end
      end

      def export_options(target)
        method = target.fetch(:platform) == "MAC_OS" ? "developer-id" : "release-testing"
        <<~PLIST
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
            <key>destination</key>
            <string>export</string>
            <key>method</key>
            <string>#{method}</string>
            #{target.fetch(:platform) == "MAC_OS" ? "<key>signingCertificate</key>\n    <string>Developer ID Application</string>" : ""}
            <key>signingStyle</key>
            <string>automatic</string>
            <key>teamID</key>
            <string>#{ENV.fetch("APPLE_TEAM_ID")}</string>
          </dict>
          </plist>
        PLIST
      end

      def revision_product(target)
        extension = target.fetch(:platform) == "MAC_OS" ? "app" : "ipa"
        products = Dir.glob(File.join(Apps.revision_export_path(target), "*.#{extension}"))
        raise "Missing revision for #{target.fetch(:name)}" unless products.one?

        product = products.fetch(0)
        return product unless target.fetch(:platform) == "MAC_OS"

        named_product = File.join(Apps.revision_export_path(target), "#{Apps.config.fetch(:name)}.app")
        FileUtils.mv(product, named_product) unless product == named_product
        named_product
      end

      def upload(repository, target)
        return if Cache.get(cache_key(repository, target)).present?

        release = release(repository)
        name = File.basename(Apps.revision_path(target))
        content = File.binread(Apps.revision_path(target))
        assets = release.fetch(:assets, [])
        obsolete_assets(assets, target, name).each do |item|
          delete_asset(repository, release.fetch(:id), item.fetch(:id))
        end
        asset = assets.find { |item| item.fetch(:name) == name }
        unless asset_matches?(repository, asset, content)
          delete_asset(repository, release.fetch(:id), asset.fetch(:id)) if asset.present?
          upload_asset(repository, release.fetch(:id), name, content)
        end
        Cache.set(cache_key(repository, target), "uploaded")
      end

      def obsolete_assets(assets, target, name)
        suffix = "-#{target.fetch(:name)}-#{Apps.version}.#{File.extname(name).delete_prefix(".")}"
        assets.select { |item| item.fetch(:name) != name && item.fetch(:name).end_with?(suffix) }
      end

      def asset_matches?(repository, asset, content)
        return false if asset.blank?
        return asset.fetch(:digest, "") == "sha256:#{Digest::SHA256.hexdigest(content)}" if repository.fetch(:host) == "github.com"

        asset.fetch(:size, 0) == content.bytesize
      end

      def delete_asset(repository, release_id, asset_id)
        path = if repository.fetch(:host) == "github.com"
          "repos/#{repository.fetch(:owner)}/#{repository.fetch(:name)}/releases/assets/#{asset_id}"
        else
          "repos/#{repository.fetch(:owner)}/#{repository.fetch(:name)}/releases/#{release_id}/assets/#{asset_id}"
        end
        Req.call(url: "#{repository.fetch(:api)}/#{path}", method: :delete, headers: headers(repository))
      end

      def release(repository)
        release = Req.call(
          url: "#{repository.fetch(:api)}/repos/#{repository.fetch(:owner)}/#{repository.fetch(:name)}/releases",
          headers: headers(repository),
          params: repository.fetch(:host) == "github.com" ? { per_page: 100 } : { limit: 50 },
        ).find { |item| item.fetch(:tag_name) == tag }
        return release if release.present?

        Req.call(
          url: "#{repository.fetch(:api)}/repos/#{repository.fetch(:owner)}/#{repository.fetch(:name)}/releases",
          method: :post,
          headers: headers(repository),
          payload: { tag_name: tag, name: tag, body: Apps.config.fetch(:whatsNew), draft: false, prerelease: false },
        )
      end

      def upload_asset(repository, release_id, name, content)
        if repository.fetch(:host) == "github.com"
          Req.call(
            url: "https://uploads.github.com/repos/#{repository.fetch(:owner)}/#{repository.fetch(:name)}/releases/#{release_id}/assets",
            method: :post,
            headers: headers(repository).merge("Content-Type" => "application/zip"),
            params: { name: },
            body: content,
          )
        else
          boundary = "CodemotoRevision"
          body = "--#{boundary}\r\nContent-Disposition: form-data; name=\"attachment\"; filename=\"#{name}\"\r\nContent-Type: application/zip\r\n\r\n".b
          body << content << "\r\n--#{boundary}--\r\n".b
          Req.call(
            url: "#{repository.fetch(:api)}/repos/#{repository.fetch(:owner)}/#{repository.fetch(:name)}/releases/#{release_id}/assets",
            method: :post,
            headers: headers(repository).merge("Content-Type" => "multipart/form-data; boundary=#{boundary}"),
            body:,
          )
        end
      end

      def headers(repository)
        if repository.fetch(:host) == "github.com"
          {
            "Accept" => "application/vnd.github+json",
            "Authorization" => "Bearer #{repository.fetch(:token)}",
            "X-GitHub-Api-Version" => "2022-11-28",
          }
        else
          { "Authorization" => "token #{repository.fetch(:token)}" }
        end
      end

      def tag = "v#{Apps.version}"

      def cache_key(repository, target)
        "apps/#{Apps.version}/#{target.fetch(:name)}/revisions/v3/#{repository.fetch(:host)}"
      end
    end
  end
end
