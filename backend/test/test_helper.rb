ENV["RAILS_ENV"] = "test"
require "test_safety"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "webmock/minitest"

ENV["CRYPT_KEY"] = "test_key_123"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors) unless ENV["PROFILE"]

    def setup
      WebMock.reset!
      WebMock::StubRegistry.instance.instance_variable_get(:@request_stubs).clear
      WebMock.disable_net_connect!
    end
  end
end
