# frozen_string_literal: true

require "addressable"

class Link
  class << self
    def url?(x)
      x.to_s.start_with?("http://") || x.to_s.start_with?("https://")
    end

    def host(url)
      Addressable::URI.parse(clean(url)).host
    rescue StandardError => e
      raise e.class, "#{e.message} #{url}", e.backtrace
    end

    def domain(url)
      host(url)
    rescue StandardError => e
      raise e.class, "#{e.message} #{url}", e.backtrace
    end

    def path(url)
      result = Addressable::URI.parse(clean(url)).path
      blank?(result) ? "/" : result
    rescue StandardError => e
      raise e.class, "#{e.message} #{url}", e.backtrace
    end

    def path_parts(url)
      path(url).split("/").reject { |x| blank?(x) }
    end

    def query(url)
      clean(url)
        .then { |x| Addressable::URI.parse(x) }
        .query_values
        .then { |x| x || {} }
        .then { |x| deep_symbolize_keys(x) }
    rescue StandardError => e
      raise e.class, "#{e.message} #{url}", e.backtrace
    end

    def clean(url, base: nil)
      url = url.to_s.chomp.strip
      url = nil if url.empty?
      raise "url cannot be blank" if blank?(url)

      if url.start_with?("/")
        raise "not enough info for url #{url}" if blank?(base)

        url = "https://#{host(base)}#{url}"
      end
      a = Addressable::URI.parse(url)
      host = a.host&.gsub(/^www./, "")
      raise "url cannot be blank" if blank?(host)

      port = a.port
      port_str = port && port != 443 && port != 80 ? ":#{port}" : ""
      query = a.query
      path = a.path
      path = "/" if blank?(path)
      path = path[..-2] if path.length > 1 && path.end_with?("/")
      path = path[..-2] if path.length > 1 && path.end_with?("/")
      path = path.gsub(%r{/+}, "/")
      path = Addressable::URI.unencode(path)
      query = blank?(query) ? nil : "?#{query.chomp('&')}"
      result = "https://#{host}#{port_str}#{path}#{query}"
      result = result[..-2] if result.end_with?("/") && path == "/" && blank?(query)
      result
    rescue StandardError => e
      raise e.class, "#{e.message} #{url}", e.backtrace
    end

    def likely_rss?(url)
      [ ".xml", ".rss", ".atom", "/feed", "/rss", "rss.php", "feed.xml" ].any? do |x|
        return true if path(url).end_with?(x)
      end

      [ "medium.com/feed/", "hnrss.org", "/feed/", "/feeds/", "?format=rss", "?format=rss2", "?feed=rss2", "?feed=rss",
        "?format=xml" ].any? do |x|
        return true if url.include?(x)
      end

      [ "feeds.", "feed." ].any? do |x|
        return true if domain(url).start_with?(x)
      end

      false
    end

    def likely_media?(url)
      Path.media?(path(url))
    end

    private

    def blank?(obj)
      return true if obj.nil?
      return obj.empty? if obj.respond_to?(:empty?)

      false
    end

    def deep_symbolize_keys(hash)
      hash.transform_keys(&:to_sym).transform_values do |value|
        value.is_a?(Hash) ? deep_symbolize_keys(value) : value
      end
    end
  end
end
