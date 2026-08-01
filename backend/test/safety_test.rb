require "test_helper"

class SafetyTest < ActiveSupport::TestCase
  test "blocks commands" do
    assert_raises(UnsafeTestOperation) { system("true") }
    assert_raises(UnsafeTestOperation) { `true` }
    assert_raises(UnsafeTestOperation) { Process.spawn("true") }
    assert_raises(UnsafeTestOperation) { IO.popen("true") }
  end

  test "blocks network calls" do
    assert_raises(UnsafeTestOperation) { TCPSocket.new("example.com", 80) }
  end
end
