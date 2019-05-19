$: << 'lib'
require 'dpl'

def gems
  skip = %i(bit_balloon help)
  consts = Dpl::Provider.registry
  consts = consts.reject { |key, _| skip.include?(key) }.to_h
  consts.values.map(&:gem).flatten(1).uniq
end

source 'https://rubygems.org'
ruby '>= 2.2'

gemspec name: 'dpl'
# gem 'cl', path: '../../cl'

# https://github.com/BitBalloon/bitballoon-ruby/pull/14
gem 'bitballoon', git: 'https://github.com/travis-repos/bitballoon-ruby'

gems.each do |name, version, opts|
  gem name, version, opts
end

group :test do
  gem 'rspec'
  gem 'webmock'
end
