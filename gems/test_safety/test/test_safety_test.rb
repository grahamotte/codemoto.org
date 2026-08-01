require_relative "test_helper"

class TestSafetyTest < Minitest::Test
  def test_stubs_project_sleeps
    assert_equal 3, sleep(3)
  end

  def test_blocks_commands
    assert_raises(UnsafeTestOperation) { system("true") }
    assert_raises(UnsafeTestOperation) { `true` }
    assert_raises(UnsafeTestOperation) { Process.spawn("true") }
    assert_raises(UnsafeTestOperation) { Process.fork }
    assert_raises(UnsafeTestOperation) { IO.popen("true") }
  end

  def test_blocks_network_calls
    assert_raises(UnsafeTestOperation) { TCPSocket.new("example.com", 80) }
  end
end
