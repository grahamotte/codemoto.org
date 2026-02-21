class DropSolidQueueTables < ActiveRecord::Migration[8.1]
  TABLES = [
    :solid_queue_blocked_executions,
    :solid_queue_claimed_executions,
    :solid_queue_failed_executions,
    :solid_queue_ready_executions,
    :solid_queue_recurring_executions,
    :solid_queue_scheduled_executions,
    :solid_queue_jobs,
    :solid_queue_pauses,
    :solid_queue_processes,
    :solid_queue_recurring_tasks,
    :solid_queue_semaphores,
  ]

  def up
    TABLES.each do |table|
      drop_table table, if_exists: true
    end
  end

  def down = nil
end
