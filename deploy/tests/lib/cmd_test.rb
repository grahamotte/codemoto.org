require_relative "../test_helper"

class CmdTest < Minitest::Test
  def test_local_escapes_arguments_and_returns_output
    Cmd.expects(:`).with("echo hello\\ world").returns("hello world\n")
    result = nil

    output, = capture_io { result = DeployTestMethods::CMD_LOCAL.call("echo ?", "hello world") }

    assert_equal "hello world\n", result
    assert_includes output, "CMD echo hello\\ world"
  end
end
