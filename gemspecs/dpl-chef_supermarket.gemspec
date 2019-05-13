require './gemspec_helper'

deps = [
  ['rack'],
  ['mime-types'],
]

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
  gemspec_for 'chef_supermarket', [['rack'], ['mime-types'], ['net-telnet', '~> 0.1.0'], ['chef', '~> 12.0']]
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 13.0'])
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.5.0")
  gemspec_for 'chef_supermarket', (deps << ['chef', '~> 14.0'])
else
  gemspec_for 'chef_supermarket', (deps << ['chef', '>= 14'])
end
