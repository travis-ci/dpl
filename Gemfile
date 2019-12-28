$: << 'lib'
require 'dpl/support/gems'

source 'https://rubygems.org'
ruby '>= 2.2'

gemspec name: 'dpl'
# gem 'cl', path: '../../cl'
# gem 'regstry', path: '../../registry'

gems = Dpl::Support::Gems.new('lib/dpl/providers/**/*.rb')
gems.each do |name, version, opts|
  gem name, version, opts
end

group :test do
  gem 'coveralls'
  gem 'rspec'
  gem 'webmock'
end
