require './gemspec_helper'

deps = [
  ['rack'],
  ['mime-types'],
]

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
    deps << ['net-telnet', '~> 0.1.0'] << ['chef', '~> 12.0'] << ['public_suffix', '< 3.1.0']
    gemspec_for 'chef_supermarket', deps
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 13.0'] << ['openssl'])
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 14.0'] << ['openssl'])
else
  gemspec_for 'chef_supermarket', (deps << ['chef', '>= 14'] << ['openssl'])
end
