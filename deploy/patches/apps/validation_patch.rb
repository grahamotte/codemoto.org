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
        %i[
          build
          contactEmail
          contactFirstName
          contactLastName
          contactPhone
          copyright
          description
          keywords
          marketingUrl
          notes
          promotionalText
          releaseType
          supportUrl
          whatsNew
        ].each do |field|
          raise "Missing #{field} in app configuration" if Apps.config[field].blank?
        end
        raise "Missing demoAccountRequired in app configuration" unless Apps.config.key?(:demoAccountRequired)
        return unless Apps.config.fetch(:demoAccountRequired)

        %i[demoAccountName demoAccountPassword].each do |field|
          raise "Missing #{field} in app configuration" if Apps.config[field].blank?
        end
      end

      def validate_targets
        raise "No Apple targets configured" if Apps.targets.blank?
        raise "Missing #{Apps.export_options_path}" unless File.file?(Apps.export_options_path)

        Apps.targets.each do |target|
          %i[archiveDestination bundleIdentifier platform project scheme screenshots].each do |field|
            raise "Missing #{field} for #{target.fetch(:name)}" if target[field].blank?
          end
          raise "Missing #{target.fetch(:project)}" unless File.directory?(Apps.project_path(target))
          target.fetch(:screenshots).each do |screenshot|
            %i[displayType path].each do |field|
              raise "Missing screenshot #{field} for #{target.fetch(:name)}" if screenshot[field].blank?
            end
            raise "Missing #{screenshot.fetch(:path)}" unless File.file?(Apps.screenshot_path(screenshot))
          end
        end
      end
    end
  end
end
