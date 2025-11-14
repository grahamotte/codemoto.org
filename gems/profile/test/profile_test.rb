# frozen_string_literal: true

require_relative 'test_helper'

class ProfileTest < Minitest::Test
  def test_call_requires_block
    assert_raises(ArgumentError) do
      Profile.call
    end
  end
end
