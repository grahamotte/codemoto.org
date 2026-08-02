module Apps
  class BuildPatch < BasePatch
    class << self
      def needed?
        Apps.targets.any? { |target| !File.directory?(Apps.archive_path(target)) }
      end

      def apply
        Apps.targets.each do |target|
          next if File.directory?(Apps.archive_path(target))

          puts "Building #{target.fetch(:name)}..."
          FileUtils.mkdir_p(File.dirname(Apps.archive_path(target)))
          Cmd.local(Shellwords.join([
            "xcodebuild",
            "archive",
            "-project",
            Apps.project_path(target),
            "-scheme",
            target.fetch(:scheme),
            "-configuration",
            "Release",
            "-destination",
            target.fetch(:archiveDestination),
            "-archivePath",
            Apps.archive_path(target),
            "-allowProvisioningUpdates",
            "MARKETING_VERSION=#{Apps.version}",
            "CURRENT_PROJECT_VERSION=#{Apps.build}",
            "PRODUCT_BUNDLE_IDENTIFIER=#{target.fetch(:bundleIdentifier)}",
            "DEVELOPMENT_TEAM=#{ENV.fetch("APPLE_TEAM_ID")}",
            *Apps.authentication_arguments,
          ]))
        end
      end
    end
  end
end
