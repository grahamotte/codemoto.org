require "test_helper"

class AgentTest < ActiveSupport::TestCase
  class FakeAgent < Agent
    class << self
      attr_accessor :result, :captured_command, :captured_environment, :captured_options
    end

    private

    def capture
      self.class.captured_command = command
      self.class.captured_environment = environment
      self.class.captured_options = options
      self.class.result
    end
  end

  def setup
    @original_token = ENV["OPENROUTER_TOKEN"]
    ENV["OPENROUTER_TOKEN"] = "test-token"
    FakeAgent.result = nil
    FakeAgent.captured_command = nil
    FakeAgent.captured_environment = nil
    FakeAgent.captured_options = nil
  end

  def teardown
    ENV["OPENROUTER_TOKEN"] = @original_token
  end

  def test_call
    FakeAgent.result = [
      [
        JSON.generate(type: "step_start", part: { type: "step-start" }),
        JSON.generate(type: "text", part: { type: "text", text: "First response" }),
        JSON.generate(type: "tool_use", part: { type: "tool" }),
        JSON.generate(type: "reasoning", part: { type: "reasoning", text: "Thinking" }),
        JSON.generate(type: "text", part: { type: "text", text: "Second response" }),
      ].join("\n"),
      "",
      status(success: true),
    ]

    result = FakeAgent.call(
      model: "anthropic/claude-sonnet-4",
      effort: "high",
      prompt: "Answer this prompt",
    )

    assert_equal [ "First response", "Second response" ], result
    assert_equal [
      "opencode",
      "run",
      "--format",
      "json",
      "--model",
      "openrouter/anthropic/claude-sonnet-4",
      "--variant",
      "high",
    ], FakeAgent.captured_command
    assert_equal({ "OPENROUTER_API_KEY" => "test-token" }, FakeAgent.captured_environment)
    assert_equal "Answer this prompt", FakeAgent.captured_options.fetch(:stdin_data)
    assert_equal Rails.root.to_s, FakeAgent.captured_options.fetch(:chdir)
  end

  def test_call_prefixes_openrouter
    FakeAgent.result = [ "", "", status(success: true) ]

    FakeAgent.call(model: "deepseek/deepseek-v4-flash", effort: "high", prompt: "Prompt")

    assert_includes FakeAgent.captured_command, "openrouter/deepseek/deepseek-v4-flash"
  end

  def test_call_keeps_openrouter_prefix
    FakeAgent.result = [ "", "", status(success: true) ]

    FakeAgent.call(model: "openrouter/deepseek/deepseek-v4-flash", effort: "high", prompt: "Prompt")

    assert_equal "openrouter/deepseek/deepseek-v4-flash", FakeAgent.captured_command[FakeAgent.captured_command.index("--model") + 1]
  end

  def test_call_with_defaults
    FakeAgent.result = [ "", "", status(success: true) ]

    FakeAgent.call(prompt: "Prompt")

    assert_includes FakeAgent.captured_command, "openrouter/deepseek/deepseek-v4-flash"
    assert_includes FakeAgent.captured_command, "high"
  end

  def test_call_with_no_responses
    FakeAgent.result = [ "", "", status(success: true) ]

    assert_equal [], FakeAgent.call(model: "provider/model", effort: "low", prompt: "Prompt")
  end

  def test_call_with_failed_process
    FakeAgent.result = [ "", "Provider unavailable\n", status(success: false) ]

    error = assert_raises(RuntimeError) do
      FakeAgent.call(model: "provider/model", effort: "low", prompt: "Prompt")
    end

    assert_equal "Agent failed: Provider unavailable", error.message
  end

  def test_call_with_invalid_json
    FakeAgent.result = [ "not json", "", status(success: true) ]

    assert_raises(JSON::ParserError) do
      FakeAgent.call(model: "provider/model", effort: "low", prompt: "Prompt")
    end
  end

  def test_call_without_token
    ENV.delete("OPENROUTER_TOKEN")
    FakeAgent.result = [ "", "", status(success: true) ]

    assert_raises(KeyError) do
      FakeAgent.call(model: "provider/model", effort: "low", prompt: "Prompt")
    end
  end

  private

  def status(success:)
    Object.new.tap { |object| object.define_singleton_method(:success?) { success } }
  end
end
