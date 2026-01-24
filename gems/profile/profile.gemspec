# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'profile'
  spec.version = '0.0.0'
  spec.authors = [ 'Graham Otte' ]
  spec.summary = 'Simple profiling utility for graham.lol'
  spec.required_ruby_version = '>= 3.0'
  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = [ 'lib' ]

  spec.add_dependency 'vernier', '~> 1.0'

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rails-omakase'
  spec.add_development_dependency 'rubocop-minitest'
end
