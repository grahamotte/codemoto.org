# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "path"
  spec.version = "0.0.0"
  spec.authors = [ "Graham Otte" ]
  spec.summary = "Simple path utility for graham.lol"
  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = [ "lib" ]

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rails-omakase"
end
