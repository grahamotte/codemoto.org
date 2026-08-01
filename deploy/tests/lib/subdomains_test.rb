require_relative "../test_helper"

class SubdomainsTest < Minitest::Test
  def setup
    Subdomains.instance_variable_set(:@all, nil)
  end

  def test_domains
    Constants.stubs(:domain).returns("example.com")

    assert_equal(
      [ "example.com", "www.example.com" ],
      Subdomains.domains(subdomains: [ "", "www" ]),
    )
  end

  def test_all_and_frontends
    subdomains = [
      { name: "www", directory: "subdomains/www", subdomains: [ "" ] },
      { name: "api", directory: nil, subdomains: [ "api" ] },
    ]
    File.expects(:read).returns(JSON.generate(subdomains))

    assert_equal [ "www", "api" ], Subdomains.all.map { |x| x[:name] }
    assert_equal [ "www" ], Subdomains.frontends.map { |x| x[:name] }
  end

  def test_all_domains_and_dist_path
    Constants.stubs(:domain).returns("example.com")
    Constants.stubs(:remote_root).returns("/app")
    Subdomains.stubs(:all).returns([
      { name: "www", subdomains: [ "", "www" ] },
      { name: "api", subdomains: [ "api" ] },
    ])

    assert_equal [ "example.com", "www.example.com", "api.example.com" ], Subdomains.domains
    assert_equal "/app/frontend/dist/www", Subdomains.dist(name: "www")
  end
end
