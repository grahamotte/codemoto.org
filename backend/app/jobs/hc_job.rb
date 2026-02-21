class HcJob < ApplicationJob
  schedule "every 1 hour"

  def perform
    sleep 1
  end
end
