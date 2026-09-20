class Watch
  class << self
    def call
      Linear.sync_statuses
      Trigger.call
    rescue Faraday::Error => error
      puts error.full_message
    end
  end
end
