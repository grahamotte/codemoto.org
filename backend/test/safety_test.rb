require "test_helper"

class SafetyTest < ActiveSupport::TestCase
  test "blocks commands" do
    assert_raises(UnsafeTestOperation) { system("true") }
    assert_raises(UnsafeTestOperation) { `true` }
    assert_raises(UnsafeTestOperation) { Process.spawn("true") }
    assert_raises(UnsafeTestOperation) { IO.popen("true") }
  end

  test "blocks network calls" do
    assert_raises(UnsafeTestOperation) { TCPSocket.new("example.com", 80) }
  end

  test "business logic has one unit test file" do
    sources = [
      *Dir[Rails.root.join("app/controllers/**/*.rb")].reject { |path| path.end_with?("application_controller.rb") },
      *Dir[Rails.root.join("app/jobs/**/*.rb")],
      *Dir[Rails.root.join("app/services/**/*.rb")],
    ]
    expected = sources.map do |path|
      path.sub("#{Rails.root}/app/", "#{Rails.root}/test/").sub(/\.rb\z/, "_test.rb")
    end

    assert_equal [], expected.reject { |path| File.file?(path) }
  end

  test "unit tests do not use integration tests or cross-unit mocks" do
    tests = Dir[Rails.root.join("test/**/*_test.rb")]
      .reject { |path| path.end_with?("safety_test.rb") }
      .map { |path| File.read(path) }
      .join("\n")

    refute_match(/IntegrationTest/, tests)
    refute_match(/\.(?:stubs|expects)\(/, tests)
  end
end
