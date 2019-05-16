ruby_version = Gem::Version.new(RUBY_VERSION)
pre_ruby_2_3 = ruby_version < Gem::Version.new("2.3.0")
pre_ruby_2_4 = ruby_version < Gem::Version.new("2.4.0")

source 'https://rubygems.org'
ruby '>= 2.2'

gemspec name: 'dpl'
# gem 'cl', git: 'https://github.com/svenfuchs/cl', ref: 'sf-v0.1.0'
# gem 'cl', path: '../../cl'

# chef_supermarket
gem 'chef',               pre_ruby_2_3 ? '~> 12.0' : pre_ruby_2_4 ? '~> 13.0' : '>= 14'
gem 'net-telnet',         '~> 0.1.0' if pre_ruby_2_3
gem 'mime-types',         '~> 3.0'
gem 'rack',               '~> 2.0.7'

# cloud_files
gem 'fog-core',           '= 2.1.0' # https://github.com/fog/fog-rackspace/issues/29
gem 'fog-rackspace',      '~> 0.1.6'
gem 'nokogiri',           '< 1.10'

# code_deploy, elastic_beanstalk, lambda, s3
gem 'aws-sdk',            '~> 2.0'
gem 'mime-types',         '~> 3.0'
gem 'rubyzip',            '~> 1.2.2'

# engine_yard
gem 'engineyard-cloud-client', '~> 2.1.0'

# gcs
gem 'gstore',             '~> 0.2.1'
gem 'mime-types',         '~> 3.0'

# heroku
gem 'faraday',            '~> 0.15.4'
gem 'rendezvous',         '~> 0.1.3'
gem 'netrc',              '~> 0.11.0'

# open_shift
gem 'httpclient',         '~> 2.4.0'
gem 'net-ssh',            '~> 4.2.0'
gem 'net-ssh-gateway',    '~> 2.0.0'
gem 'rhc',                '~> 1.38.7'

# packagecloud
gem 'packagecloud-ruby', '~> 1.0.8'

# pages, releases
gem 'octokit',           '~> 4.6.2'
gem 'mime-types',        '~> 3.0'

# puppet_forge
gem 'puppet',            '~> 5'
gem 'puppet-blacksmith', '~> 3.3.1'

# rubygems
gem 'gems',              '~> 1.1.0'

# testfairy
gem 'multipart-post',    '~> 2.0.0'

group :test do
  gem 'rspec'
  gem 'webmock'
end
