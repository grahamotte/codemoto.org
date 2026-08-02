require_relative "test_helper"

class SafetyTest < Minitest::Test
  def test_blocks_commands
    assert_raises(UnsafeTestOperation) { system("true") }
    assert_raises(UnsafeTestOperation) { `true` }
    assert_raises(UnsafeTestOperation) { Process.spawn("true") }
    assert_raises(UnsafeTestOperation) { IO.popen("true") }
    assert_raises(UnsafeTestOperation) { Cmd.local("true") }
    assert_raises(UnsafeTestOperation) { Cmd.ssh("true") }
  end

  def test_blocks_requests
    assert_raises(UnsafeTestOperation) { Req.call(url: "https://example.com") }
    assert_raises(WebMock::NetConnectNotAllowedError) { Faraday.get("https://example.com") }
    assert_raises(UnsafeTestOperation) { TCPSocket.new("example.com", 80) }
  end

  def test_patches_have_one_unit_test_file
    source_root = File.expand_path("../patches", __dir__)
    test_root = File.join(__dir__, "patches")
    sources = Dir[File.join(source_root, "**/*.rb")]
      .map { |path| path.delete_prefix("#{source_root}/").delete_suffix(".rb") }
      .sort
    tests = Dir[File.join(test_root, "**/*_test.rb")]
      .map { |path| path.delete_prefix("#{test_root}/").delete_suffix("_test.rb") }
      .sort

    assert_equal sources, tests
  end

  def test_frontend_and_gems_have_one_unit_test_file
    frontend_sources = Dir[File.join($root_dir, "frontend/{components,utils}/*.{ts,tsx}")]
      .map { |path| File.basename(path).sub(/\.tsx?\z/, "") }
      .sort
    frontend_tests = Dir[File.join($root_dir, "frontend/tests/{components,utils}/*.test.{ts,tsx}")]
      .map { |path| File.basename(path).sub(/\.test\.tsx?\z/, "") }
      .sort
    gem_sources = Dir[File.join($root_dir, "gems/*/lib/*.rb")]
    missing_gem_tests = gem_sources.reject do |path|
      gem_root = File.dirname(File.dirname(path))
      File.file?(File.join(gem_root, "test", "#{File.basename(path, ".rb")}_test.rb"))
    end

    assert_equal frontend_sources, frontend_tests
    assert_equal [], missing_gem_tests
  end

  def test_unit_tests_only_mock_boundaries
    tests = Dir[File.join(__dir__, "**/*_test.rb")]
      .reject { |path| path.end_with?("safety_test.rb") }
      .map { |path| File.read(path) }
      .join("\n")

    refute_match(/\b(?!Cmd|Req)\w+\.(?:stubs|expects)\(/, tests)
  end
end
