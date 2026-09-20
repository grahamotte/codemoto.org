require "bundler/setup"
require "minitest/autorun"
require "minitest/parallel_fork"
require "mocha/minitest"
require "webmock/minitest"
require "test_safety"
WebMock.disable_net_connect!
def Minitest.parallel_fork_number = 4

require_relative "../lib/require"

module ManagerTestMethods
  REQ_CALL = Req.method(:call)

  def req_opts(args, kwargs)
    kwargs.present? ? kwargs : args.first
  end
end

Req.define_singleton_method(:call) { |*, **| raise UnsafeTestOperation, "Req.call must be stubbed in manager tests" }

{
  "PLANE_TOKEN" => "plane-token",
  "PLANE_WORKSPACE" => "otte",
  "PLANE_PROJECT" => "MOTO",
  "AGENT_RUNNER" => "openchamber",
  "AGENT_MODEL" => "xai/grok-4.6",
  "AGENT_VARIANT" => "high",
  "test" => "true",
}.each { |key, value| ENV[key] = value }

module ManagerTestIsolation
  def before_setup
    Plane.reset
    super
  end
end

Minitest::Test.include(ManagerTestMethods)
Minitest::Test.prepend(ManagerTestIsolation)
