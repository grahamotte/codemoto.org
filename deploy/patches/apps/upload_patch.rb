module Apps
  class UploadPatch < BasePatch
    class << self
      def needed?
        Apps.targets.any? { |target| Cache.get(cache_key(target)).blank? }
      end

      def apply
        Apps.targets.each do |target|
          next if Cache.get(cache_key(target)).present?

          raise "Missing archive for #{target.fetch(:name)}" unless File.directory?(Apps.archive_path(target))

          puts "Uploading #{target.fetch(:name)}..."
          FileUtils.rm_rf(Apps.export_path(target))
          Cmd.local(Shellwords.join([
            "xcodebuild",
            "-exportArchive",
            "-archivePath",
            Apps.archive_path(target),
            "-exportPath",
            Apps.export_path(target),
            "-exportOptionsPlist",
            Apps.export_options_path,
            "-allowProvisioningUpdates",
            *Apps.authentication_arguments,
          ]))
          Cache.set(cache_key(target), "uploaded")
        end
      end

      private

      def cache_key(target)
        "apps/#{Apps.version}/#{target.fetch(:name)}/uploaded"
      end
    end
  end
end
