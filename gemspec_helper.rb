$:.unshift File.expand_path("../lib", __FILE__)
require "dpl/version"

def gemspec_for(provider_name=nil, runtime_dependencies=[])
  Gem::Specification.new do |s|

    s.name                  = ["dpl", provider_name].compact.join("-")
    s.author                = "Konstantin Haase"
    s.email                 = "konstantin.mailinglists@googlemail.com"
    s.homepage              = "https://github.com/travis-ci/dpl"
    s.summary               = %q{deploy tool}
    s.description           = %q{deploy tool abstraction for clients}
    s.license               = 'MIT'

    s.require_path          = 'lib'
    s.required_ruby_version = '>= 2.2'

    # set up version
    s.version = ENV['DPL_VERSION'] || DPL::VERSION

    # dependencies
    if provider_name
      s.add_runtime_dependency 'dpl', s.version
    end

    runtime_dependencies.each do |part|
      s.add_runtime_dependency *part
    end

    s.add_development_dependency 'rspec'
    s.add_development_dependency 'rspec-its'
    s.add_development_dependency 'rake'
    s.add_development_dependency 'json_pure'
    s.add_development_dependency 'tins'
    s.add_development_dependency 'coveralls'
    s.add_development_dependency 'highline'
    s.add_development_dependency 'term-ansicolor'
    s.add_development_dependency 'faraday'

    # set up files
    if provider_name
      s.files       = `git ls-files`.split("\n").grep(Regexp.new provider_name.to_s)
      s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n").grep(Regexp.new provider_name.to_s)
    else
      s.files      = `git ls-files`.split("\n").reject {|f| f =~ Regexp.new("provider/")}
      s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n").reject {|f| f =~ Regexp.new("provider/")}
    end
    s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }.grep(Regexp.new provider_name.to_s)

   end
end