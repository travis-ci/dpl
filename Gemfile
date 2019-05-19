$: << 'lib'
require 'dpl/support/gems'

source 'https://rubygems.org'
ruby '>= 2.2'

gemspec name: 'dpl'
# gem 'cl', path: '../../cl'

gems = Dpl::Support::Gems.new('lib/dpl/providers/**/*.rb', except: :bit_balloon)
gems.each do |name, version, opts|
  gem name, version, opts
end

# https://github.com/BitBalloon/bitballoon-ruby/pull/14
gem 'bitballoon', git: 'https://github.com/travis-repos/bitballoon-ruby'

group :test do
  gem 'rspec'
  gem 'webmock'
end
