# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "fileutils"
require "securerandom"
require "digest"
require "json"
require "base64"
require "tmpdir"
require "test_safety"

require_relative "../lib/path"
