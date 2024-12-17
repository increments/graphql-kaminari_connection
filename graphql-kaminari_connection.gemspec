# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/kaminari_connection/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-kaminari_connection'
  spec.version       = GraphQL::KaminariConnection::VERSION
  spec.authors       = ['Yuku TAKAHASHI']
  spec.email         = ['yuku@qiita.com']

  spec.summary       = 'Kaminari based GraphQL pagination'
  spec.homepage      = 'https://github.com/increments/graphql-kaminari_connection'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_dependency 'graphql', '~> 1.9'
  spec.add_dependency 'kaminari', '~> 1.1'

  spec.add_development_dependency 'activerecord', '~> 6.0'
  spec.add_development_dependency 'bundler', '~> 2.2'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  spec.add_development_dependency 'pry', '0.11.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.69.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 3.3.0'
  spec.add_development_dependency 'simplecov', '~> 0.13'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
