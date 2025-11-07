class InstanceDestroyPatch < BasePatch
  class << self
    def always
      Instance.destroy
    end
  end
end
