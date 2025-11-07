class DeployResetter
  class << self
    def call
      write_recurring_tasks
      mark_running_jobs_as_blocked
    end

    def mark_running_jobs_as_blocked
      ActiveRecord::Base.connection.execute("TRUNCATE solid_queue_jobs CASCADE")
      ActiveRecord::Base.connection.execute("TRUNCATE solid_queue_semaphores CASCADE")
      ActiveRecord::Base.connection.execute("TRUNCATE solid_queue_scheduled_executions CASCADE")
    end

    def write_recurring_tasks
      the_schedule = Dir[Rails.root.join("app/jobs/**/*.rb")]
        .reject { |path| path.end_with?("application_job.rb") }
        .select { |path| path.end_with?("_job.rb") }
        .map do |path|
          relative_path = path.sub("#{Rails.root.join("app/jobs")}/", "").sub(".rb", "")
          class_name = relative_path.camelize
          [ class_name, class_name.constantize.schedule_interval ]
        end
        .reject { |klass, schedule| schedule.blank? }
        .to_h
        .map do |klass, schedule|
          [
            klass.gsub("::", ""),
            {
              "class" => klass,
              "schedule" => schedule,
            },
          ]
        end
        .to_h


      Path.write(
        {
          "production" => the_schedule,
          "development" => {},
        }.to_yaml,
        Rails.root.join("config/recurring.yml"),
      )
    end
  end
end

# ActiveRecord::Base.connection.truncate("solid_cache_entries")
# ActiveRecord::Base.connection.truncate("solid_queue_blocked_executions")
# ActiveRecord::Base.connection.truncate("solid_queue_claimed_executions")
# ActiveRecord::Base.connection.truncate("solid_queue_failed_executions")
# ActiveRecord::Base.connection.truncate("solid_queue_pauses")
# ActiveRecord::Base.connection.truncate("solid_queue_processes")
# ActiveRecord::Base.connection.truncate("solid_queue_ready_executions")
# ActiveRecord::Base.connection.truncate("solid_queue_recurring_executions")
# ActiveRecord::Base.connection.truncate("solid_queue_recurring_tasks")
# ActiveRecord::Base.connection.truncate("solid_queue_scheduled_executions")
# ActiveRecord::Base.connection.truncate("solid_queue_semaphores")
# ActiveRecord::Base.connection.execute("TRUNCATE solid_queue_jobs CASCADE")
