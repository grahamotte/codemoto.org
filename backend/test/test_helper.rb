ENV["RAILS_ENV"] = "test"
require "test_safety"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "webmock/minitest"

class Token
  def self.verify(token)
    token == "valid"
  end
end unless defined?(Token)

ENV["CRYPT_KEY"] = "test_key_123"

module ActiveSupport
  class TestCase
    parallelize(workers: 4, threshold: 0)

    def setup
      WebMock.reset!
      WebMock::StubRegistry.instance.instance_variable_get(:@request_stubs).clear
      WebMock.disable_net_connect!
    end
  end
end
