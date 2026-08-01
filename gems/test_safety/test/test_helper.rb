require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "test_safety"

Minitest.parallel_executor = Minitest::Parallel::Executor.new(4)
Minitest::Test.parallelize_me!
