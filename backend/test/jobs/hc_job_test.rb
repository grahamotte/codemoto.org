require "test_helper"

class HcJobTest < ActiveSupport::TestCase
  def test_schedule_interval
    assert_equal "every 1 minute", HcJob.schedule_interval
  end
end
