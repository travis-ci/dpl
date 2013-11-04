$:.unshift File.expand_path("../lib", __FILE__)
require "dpl/version"

Gem::Specification.new do |s|
  s.name                  = "dpl"
  s.version               = DPL::VERSION
  s.author                = "Konstantin Haase"
  s.email                 = "konstantin.mailinglists@googlemail.com"
  s.homepage              = "https://github.com/travis-ci/dpl"
  s.summary               = %q{deploy tool}
  s.description           = %q{deploy tool abstraction for clients}
  s.license               = 'MIT'
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'json'

  # prereleases from Travis CI
  s.version = s.version.to_s.succ + ".travis.#{ENV['TRAVIS_JOB_NUMBER']}" if ENV['CI']
end
