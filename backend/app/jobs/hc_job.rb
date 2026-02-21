class HcJob < ApplicationJob
  schedule "every 1 minute"

  def perform
    sleep 1
  end
end
