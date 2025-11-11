# frozen_string_literal: true

require_relative "test_helper"

class ProfileTest < Minitest::Test
  def test_call_requires_block
    assert_raises(ArgumentError) do
      Profile.call
    end
  end

  def test_call_raises_error_if_source_location_unavailable
    block = eval("proc { puts 'test' }")

    assert_raises(RuntimeError) do
      Profile.call(&block)
    end
  end
end

