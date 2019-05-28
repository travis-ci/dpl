require './gemspec_helper'

deps = [
  ['rack'],
  ['mime-types'],
  ['public_suffix', '< 3.1.0'],
  ['ohai', '~> 13.0'],
]

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
    deps << ['net-telnet', '~> 0.1.0'] << ['chef', '~> 12.0']
    gemspec_for 'chef_supermarket', deps
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 13.0'])
else
  gemspec_for 'chef_supermarket', (deps << ['chef', '>= 14'])
end
