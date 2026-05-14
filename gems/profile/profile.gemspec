# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "profile"
  spec.version = "0.0.0"
  spec.authors = [ "Graham Otte" ]
  spec.summary = "Simple profiling utility for graham.lol"
  spec.required_ruby_version = ">= 3.0"
  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "vernier", "1.10.1"

  spec.add_development_dependency "minitest", "6.0.6"
  spec.add_development_dependency "rubocop", "1.86.2"
  spec.add_development_dependency "rubocop-rails-omakase", "1.1.0"
  spec.add_development_dependency "rubocop-minitest", "0.39.1"
end
