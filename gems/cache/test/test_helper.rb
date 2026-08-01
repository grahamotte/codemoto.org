# frozen_string_literal: true

ENV['test'] = 'true'

require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "fileutils"
require "securerandom"
require "digest"
require "json"
require "tmpdir"
require "test_safety"

Minitest.parallel_executor = Minitest::Parallel::Executor.new(4)
Minitest::Test.parallelize_me!

require_relative "../lib/cache"
