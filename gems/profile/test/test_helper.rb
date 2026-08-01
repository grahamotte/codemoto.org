# frozen_string_literal: true

ENV['test'] = 'true'

require 'bundler/setup'
Bundler.require(:default)

require 'minitest/autorun'
require 'fileutils'
require 'tempfile'
require "test_safety"

require_relative '../lib/profile'
