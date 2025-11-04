class InstanceDestroyPatch < BasePatch
  class << self
    def always
      $instance.destroy
    end
  end
end
