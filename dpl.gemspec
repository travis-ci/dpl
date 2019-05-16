$: << 'lib'

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
  s.required_ruby_version = '>= 2.2'

  s.executables = ['dpl']
  s.files       = `git ls-files -- {[A-Z]*,lib/**/*}`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_runtime_dependency 'cl'
  s.add_development_dependency 'rake'
end
