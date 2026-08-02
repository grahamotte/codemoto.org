module Apps
  class SubmitPatch < BasePatch
    class << self
      def needed?
        Apps.targets.any? { |target| Cache.get(cache_key(target)).blank? }
      end

      def apply
        client = AppStoreConnect.new
        Apps.targets.each do |target|
          next if Cache.get(cache_key(target)).present?

          puts "Preparing #{target.fetch(:name)} submission..."
          status = client.submit(target)
          Cache.set(cache_key(target), status)
        end
      end

      private

      def cache_key(target)
        "apps/#{Apps.version}/#{target.fetch(:name)}/submission"
      end
    end
  end
end
