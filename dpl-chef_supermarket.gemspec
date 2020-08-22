require './gemspec_helper'

deps = [
  ['rack'],
  ['mime-types'],
]

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
    deps.shift
    deps << ['net-telnet', '~> 0.1.0'] << ['chef', '~> 12.0'] << ['public_suffix', '< 3.1.0'] << ['rack', '~> 2.1.2'] << ['ffi', '< 1.13.0']
    gemspec_for 'chef_supermarket', deps
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 13.0'])
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 14.0'])
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 15.0'] << ['chef-zero', '<= 14.0.17'])
else
  gemspec_for 'chef_supermarket', (deps << ['chef', '>= 16'])
end
