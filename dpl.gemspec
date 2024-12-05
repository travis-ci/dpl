# frozen_string_literal: true

$LOAD_PATH << 'lib'

require 'dpl/version'

Gem::Specification.new do |s|
  s.version       = Dpl::VERSION
  s.name          = 'dpl'
  s.authors       = ['Konstantin Haase', 'Hiro Asari', 'Sven Fuchs']
  s.email         = ['konstantin@travis-ci.com', 'hiro@travis-ci.com', 'sven@travis-ci.com']
  s.homepage      = 'https://github.com/travis-ci/dpl'
  s.summary       = 'Dpl runs deployments at Travis CI'
  s.description   = 'Dpl (dee-pee-ell) is a tool made for continuous deployment, running deployments at Travis CI.'
  s.license       = 'MIT'
  s.require_path  = 'lib'
  s.required_ruby_version = '>= 3.1'

  s.executables   = ['dpl']
  s.files         = Dir['{config/**/*,lib/**/*,[A-Z]*}'].reject { _1.match(/dpl.+\.gem/) }

  s.add_runtime_dependency 'logger', '~> 1.6.2'
  s.add_runtime_dependency 'net-http', '~> 0.6.0'
  s.add_runtime_dependency 'travis-cl'
  s.add_runtime_dependency 'travis-packagecloud-ruby'
  s.add_runtime_dependency 'uri', '~> 1.0.2'
  s.add_development_dependency 'rake', '~> 13.0'
end
