require "test_helper"

class HcJobTest < ActiveSupport::TestCase
  def test_schedule_interval
    assert_equal "every 1 hour", HcJob.schedule_interval
  end

  def test_perform
    assert_equal 1, HcJob.new.perform
  end
end
