require "bundler/setup"
require "minitest/autorun"
require "mocha/minitest"
require "webmock/minitest"
require "test_safety"
WebMock.disable_net_connect!

require_relative "../lib/require"

Cmd.define_singleton_method(:local) { |*, **| raise UnsafeTestOperation, "Cmd.local must be stubbed in deploy tests" }
Cmd.define_singleton_method(:ssh) { |*, **| raise UnsafeTestOperation, "Cmd.ssh must be stubbed in deploy tests" }
Cmd.define_singleton_method(:ssh_write) { |*, **| raise UnsafeTestOperation, "Cmd.ssh_write must be stubbed in deploy tests" }
Req.define_singleton_method(:call) { |*, **| raise UnsafeTestOperation, "Req.call must be stubbed in deploy tests" }
Net::SSH.define_singleton_method(:start) { |*, **| raise UnsafeTestOperation, "Net::SSH.start must be stubbed in deploy tests" }
