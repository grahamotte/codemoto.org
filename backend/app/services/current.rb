class Current < ActiveSupport::CurrentAttributes
  attribute :_job

  def self.job
    _job
  end
end
