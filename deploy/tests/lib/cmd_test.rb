require_relative "../test_helper"

class CmdTest < Minitest::Test
  def test_local_escapes_arguments_and_returns_output
    Cmd.stubs(:puts)
    Cmd.expects(:`).with("echo hello\\ world").returns("hello world\n")

    assert_equal "hello world\n", DeployTestMethods::CMD_LOCAL.call("echo ?", "hello world")
  end
end
