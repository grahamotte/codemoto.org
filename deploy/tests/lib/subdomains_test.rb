require_relative "../test_helper"

class SubdomainsTest < Minitest::Test
  def test_domains
    Constants.stubs(:domain).returns("example.com")

    assert_equal(
      [ "example.com", "www.example.com" ],
      Subdomains.domains(subdomains: [ "", "www" ]),
    )
  end
end
