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

require_relative "../lib/cache"
