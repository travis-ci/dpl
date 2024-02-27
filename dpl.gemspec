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
  s.required_ruby_version = '>= 3'

  s.executables   = ['dpl']
  s.files         = Dir['{config/**/*,lib/**/*,[A-Z]*}']

  s.add_development_dependency 'rake', '~> 13.0'
end
