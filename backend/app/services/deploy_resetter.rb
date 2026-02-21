class DeployResetter
  class << self
    def call
      mark_running_jobs_as_blocked
    end

    def mark_running_jobs_as_blocked
      connection = ActiveRecord::Base.connection
      connection.execute("TRUNCATE good_jobs CASCADE") if connection.data_source_exists?("good_jobs")
    end
  end
end
