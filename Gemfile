# frozen_string_literal: true

$LOAD_PATH << 'lib'
require 'dpl/support/gems'

source 'https://rubygems.org'
ruby '>= 3'

gemspec name: 'dpl'
# gem 'travis-cl'
# gem 'travis-packagecloud-ruby'
# gem 'json_pure', '~> 2.6'

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

group :development, :test do
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
  gem 'simplecov-console'
end
