require './gemspec_helper'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
  gemspec_for 'chef_supermarket', [['rack'], ['mime-types'], ['chef', '~> 12.0']]
else
  gemspec_for 'chef_supermarket', [['rack'], ['mime-types'], ['chef']]
end

