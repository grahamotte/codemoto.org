# frozen_string_literal: true

require_relative "test_helper"

class LinkTest < Minitest::Test
  def test_url_returns_true_for_http_urls
    assert Link.url?("http://example.com")
  end

  def test_url_returns_true_for_https_urls
    assert Link.url?("https://example.com")
  end

  def test_url_returns_false_for_non_urls
    refute Link.url?("example.com")
    refute Link.url?("/path/to/file")
    refute Link.url?("ftp://example.com")
  end

  def test_host_extracts_hostname
    assert_equal "example.com", Link.host("https://example.com/path")
    assert_equal "example.com", Link.host("https://www.example.com/path")
    assert_equal "subdomain.example.com", Link.host("https://subdomain.example.com/path")
  end

  def test_host_raises_on_invalid_url
    error = assert_raises(RuntimeError) do
      Link.host("not a url")
    end
    assert_match(/url cannot be blank/, error.message)
  end

  def test_domain_extracts_domain
    assert_equal "example.com", Link.domain("https://example.com/path")
    assert_equal "example.com", Link.domain("https://www.example.com/path")
  end

  def test_path_extracts_path_from_url
    assert_equal "/path/to/resource", Link.path("https://example.com/path/to/resource")
    assert_equal "/", Link.path("https://example.com")
    assert_equal "/page", Link.path("https://example.com/page?query=1")
  end

  def test_path_parts_splits_path_into_array
    assert_equal [ "path", "to", "resource" ], Link.path_parts("https://example.com/path/to/resource")
    assert_empty Link.path_parts("https://example.com")
    assert_equal [ "page" ], Link.path_parts("https://example.com/page")
  end

  def test_query_extracts_query_parameters
    result = Link.query("https://example.com?foo=bar&baz=qux")

    assert_equal "bar", result[:foo]
    assert_equal "qux", result[:baz]
  end

  def test_query_returns_empty_hash_for_no_query
    result = Link.query("https://example.com")

    assert_empty(result)
  end

  def test_query_symbolizes_keys
    result = Link.query("https://example.com?foo=bar")

    assert result.key?(:foo)
    refute result.key?("foo")
  end

  def test_clean_normalizes_url
    assert_equal "https://example.com/path", Link.clean("https://www.example.com/path")
    assert_equal "https://example.com/path", Link.clean("https://example.com/path/")
    assert_equal "https://example.com/path", Link.clean("https://example.com/path//")
  end

  def test_clean_removes_www
    assert_equal "https://example.com", Link.clean("https://www.example.com")
  end

  def test_clean_removes_trailing_slashes
    assert_equal "https://example.com/path", Link.clean("https://example.com/path/")
    assert_equal "https://example.com/path", Link.clean("https://example.com/path//")
  end

  def test_clean_normalizes_multiple_slashes
    assert_equal "https://example.com/path/to", Link.clean("https://example.com//path///to")
  end

  def test_clean_unencodes_path
    assert_equal "https://example.com/path with spaces", Link.clean("https://example.com/path%20with%20spaces")
  end

  def test_clean_preserves_query_string
    assert_equal "https://example.com/path?foo=bar", Link.clean("https://example.com/path?foo=bar")
  end

  def test_clean_removes_trailing_ampersand_from_query
    assert_equal "https://example.com/path?foo=bar", Link.clean("https://example.com/path?foo=bar&")
  end

  def test_clean_raises_on_blank_url
    error = assert_raises(RuntimeError) do
      Link.clean("")
    end
    assert_match(/url cannot be blank/, error.message)

    error = assert_raises(RuntimeError) do
      Link.clean("   ")
    end
    assert_match(/url cannot be blank/, error.message)
  end

  def test_clean_handles_relative_paths_with_base
    assert_equal "https://example.com/relative", Link.clean("/relative", base: "https://example.com")
    assert_equal "https://example.com/path", Link.clean("/path", base: "https://www.example.com/other")
  end

  def test_clean_raises_on_relative_path_without_base
    error = assert_raises(RuntimeError) do
      Link.clean("/relative")
    end
    assert_match(/not enough info for url/, error.message)
  end

  def test_likely_rss_detects_xml_extension
    assert Link.likely_rss?("https://example.com/feed.xml")
    assert Link.likely_rss?("https://example.com/feed.rss")
    assert Link.likely_rss?("https://example.com/feed.atom")
  end

  def test_likely_rss_detects_feed_paths
    assert Link.likely_rss?("https://example.com/feed")
    assert Link.likely_rss?("https://example.com/rss")
    assert Link.likely_rss?("https://example.com/rss.php")
  end

  def test_likely_rss_detects_feed_in_path
    assert Link.likely_rss?("https://medium.com/feed/topic")
    assert Link.likely_rss?("https://example.com/feed/")
    assert Link.likely_rss?("https://example.com/feeds/main")
  end

  def test_likely_rss_detects_rss_query_params
    assert Link.likely_rss?("https://example.com?format=rss")
    assert Link.likely_rss?("https://example.com?format=rss2")
    assert Link.likely_rss?("https://example.com?feed=rss")
    assert Link.likely_rss?("https://example.com?feed=rss2")
    assert Link.likely_rss?("https://example.com?format=xml")
  end

  def test_likely_rss_detects_feed_subdomain
    assert Link.likely_rss?("https://feeds.example.com")
    assert Link.likely_rss?("https://feed.example.com")
  end

  def test_likely_rss_detects_hnrss
    assert Link.likely_rss?("https://hnrss.org/newest")
  end

  def test_likely_rss_returns_false_for_non_rss
    refute Link.likely_rss?("https://example.com")
    refute Link.likely_rss?("https://example.com/page")
    refute Link.likely_rss?("https://example.com/article.html")
  end

  def test_likely_media_detects_media_files
    assert Link.likely_media?("https://example.com/video.mp4")
    assert Link.likely_media?("https://example.com/image.jpg")
    assert Link.likely_media?("https://example.com/audio.mp3")
  end

  def test_likely_media_returns_false_for_non_media
    refute Link.likely_media?("https://example.com/page.html")
    refute Link.likely_media?("https://example.com/document.pdf")
  end

  def test_clean_handles_complex_urls
    url = "https://www.example.com//path///to//resource/?foo=bar&baz=qux&"
    cleaned = Link.clean(url)

    assert_equal "https://example.com/path/to/resource?foo=bar&baz=qux", cleaned
  end

  def test_host_includes_url_in_error_message
    error = assert_raises(RuntimeError) do
      Link.host("   ")
    end
    assert_match(/   /, error.message)
  end

  def test_domain_includes_url_in_error_message
    error = assert_raises(RuntimeError) do
      Link.domain("   ")
    end
    assert_match(/   /, error.message)
  end

  def test_path_includes_url_in_error_message
    error = assert_raises(RuntimeError) do
      Link.path("   ")
    end
    assert_match(/   /, error.message)
  end

  def test_query_includes_url_in_error_message
    error = assert_raises(RuntimeError) do
      Link.query("   ")
    end
    assert_match(/   /, error.message)
  end

  def test_clean_handles_nil_url
    error = assert_raises(RuntimeError) do
      Link.clean(nil)
    end
    assert_match(/url cannot be blank/, error.message)
  end

  def test_path_parts_handles_empty_path
    assert_empty Link.path_parts("https://example.com/")
  end

  def test_clean_preserves_port_if_present
    assert_equal "https://example.com:8080/path", Link.clean("https://example.com:8080/path")
  end

  def test_clean_preserves_port_and_removes_www
    assert_equal "https://example.com:8080/foo", Link.clean("https://www.example.com:8080/foo/")
  end

  def test_clean_removes_trailing_slash_before_query_on_root
    assert_equal "https://example.com?x=1", Link.clean("https://www.example.com/?x=1")
  end

  def test_extract_finds_http_urls
    result = Link.extract("Check out http://example.com for more info")

    assert_equal [ "http://example.com" ], result
  end

  def test_extract_finds_https_urls
    result = Link.extract("Check out https://example.com for more info")

    assert_equal [ "https://example.com" ], result
  end

  def test_extract_finds_multiple_urls
    result = Link.extract("Visit https://foo.com and http://bar.com")

    assert_equal [ "https://foo.com", "http://bar.com" ], result
  end

  def test_extract_strips_trailing_punctuation
    result = Link.extract("See https://example.com.")

    assert_equal [ "https://example.com" ], result

    result = Link.extract("See https://example.com,")

    assert_equal [ "https://example.com" ], result

    result = Link.extract("(https://example.com)")

    assert_equal [ "https://example.com" ], result
  end

  def test_extract_strips_multiple_trailing_punctuation
    result = Link.extract("See https://example.com...).")

    assert_equal [ "https://example.com" ], result
  end

  def test_extract_returns_empty_array_when_no_urls
    result = Link.extract("No urls here")

    assert_empty(result)
  end

  def test_extract_ignores_ftp_urls
    result = Link.extract("ftp://files.example.com")

    assert_empty(result)
  end

  def test_extract_preserves_paths_and_query_strings
    result = Link.extract("Go to https://example.com/path?foo=bar for details")

    assert_equal [ "https://example.com/path?foo=bar" ], result
  end
end
