class InstanceDestroyPatch < BasePatch
  class << self
    def always
      Cloudflare.current_dns_records.each do |record|
        Cloudflare.delete_dns_record(record[:id])
      end
      Instance.destroy
    end
  end
end
