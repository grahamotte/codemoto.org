# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "link"
  spec.version = "0.0.0"
  spec.authors = [ "Graham Otte" ]
  spec.summary = "URL parsing and manipulation utility for graham.lol"
  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "addressable"
  spec.add_dependency "path"
  spec.add_dependency "uri"

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rails-omakase"
end
