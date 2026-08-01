require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  def test_job
    job = Object.new
    Current._job = job

    assert_same job, Current.job
  ensure
    Current.reset
  end
end
