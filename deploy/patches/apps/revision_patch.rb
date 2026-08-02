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

        FileUtils.mkdir_p(File.dirname(Apps.revision_path(target)))
        Cmd.local(Shellwords.join([ "codesign", "--verify", "--deep", "--strict", Apps.product_path(target) ]))
        Cmd.local(Shellwords.join([
          "ditto",
          "-c",
          "-k",
          "--keepParent",
          Apps.product_path(target),
          Apps.revision_path(target),
        ]))
      end

      def upload(repository, target)
        return if Cache.get(cache_key(repository, target)).present?

        release = release(repository)
        name = File.basename(Apps.revision_path(target))
        unless release.fetch(:assets, []).any? { |asset| asset.fetch(:name) == name }
          upload_asset(repository, release.fetch(:id), name, File.binread(Apps.revision_path(target)))
        end
        Cache.set(cache_key(repository, target), "uploaded")
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
        "apps/#{Apps.version}/#{target.fetch(:name)}/revisions/#{repository.fetch(:host)}"
      end
    end
  end
end
