require './gemspec_helper'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
    gemspec_for 'chef_supermarket', [['rack'], ['mime-types'], ['net-telnet', '~> 0.1.0'], ['chef', '~> 12.0'], ['public_suffix', '< 3.1.0']]
elsif Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4.0")
  gemspec_for 'chef_supermarket', [['rack'], ['mime-types'], ['chef', '~> 13.0'], ['public_suffix', '< 3.1.0'], ['ohai', '~> 13.0']]
else
  gemspec_for 'chef_supermarket', [['rack'], ['mime-types'], ['chef', '>= 14'], ['public_suffix', '< 3.1.0']]
end
