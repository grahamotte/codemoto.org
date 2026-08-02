module Apps
  class ValidationPatch < BasePatch
    class << self
      def apply
        Cmd.local("xcodebuild -version")
        validate_environment
        validate_release
        validate_targets
        Apps.private_key
      end

      private

      def validate_environment
        %w[APPLE_ISSUER_ID APPLE_KEY_ID APPLE_KEY_SECRET_BASE64 APPLE_TEAM_ID].each do |name|
          raise "Missing #{name}" if ENV[name].blank?
        end
      end

      def validate_release
        raise "Version metadata does not match apps/config.json" if Apps.release.fetch(:version) != Apps.version

        %i[description keywords whatsNew].each do |field|
          raise "Missing #{field} in version metadata" if Apps.release[field].blank?
        end
      end

      def validate_targets
        raise "No Apple targets configured" if Apps.targets.blank?
        raise "Missing #{Apps.export_options_path}" unless File.file?(Apps.export_options_path)

        Apps.targets.each do |target|
          %i[archiveDestination bundleIdentifier platform project scheme].each do |field|
            raise "Missing #{field} for #{target.fetch(:name)}" if target[field].blank?
          end
          raise "Missing #{target.fetch(:project)}" unless File.directory?(Apps.project_path(target))
        end
      end
    end
  end
end
