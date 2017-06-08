source 'https://rubygems.org'
gemspec

gem 'term-ansicolor', '~> 1.3.2'

platforms :mri_19 do
  gem 'slop', '~> 3.6.0'
  gem 'ohai', '~> 7.4.0'
  gem 'amq-protocol', '~> 1.9.2'
  gem 'net-ssh', '~> 2.9.2'
end

group :heroku do
  gem 'rendezvous', '~> 0.0.2'
  gem 'heroku-api', '= 0.3.16'
  gem 'anvil-cli', '~> 0.16.1'
  gem 'netrc'
  gem 'faraday'
end

group :openshift do
  gem 'rhc'
  gem 'httpclient'
end

group :appfog do
  gem 'json_pure'
  gem 'af'
end

group :rubygems do
  gem 'gems', '~> 0.8.3'
end

group :sss do
  gem 'aws-sdk', '~> 2.6.32'
  gem 'mime-types'
end

group :code_deploy do
  gem 'aws-sdk', '~> 2.6.32'
end

group :lambda do
  gem 'aws-sdk', '~> 2.6.32'
  gem 'rubyzip', '~> 1.1'
end

group :cloud_files do
  gem 'fog-google', '< 0.1.1', platforms: :mri_19
  gem 'fog-profitbricks', '< 2.0', platforms: :mri_19
  gem 'fog'
  gem 'nokogiri', '~> 1.6.8.1'
end

group :releases do
  gem 'octokit', '~> 4.3.0'
end

group :gcs do
  gem 'gstore'
  gem 'mime-types'
end

group :elastic_beanstalk do
  gem 'aws-sdk', '~> 2.6.32'
  gem 'rubyzip', '~> 1.1'
end

group :bitballoon do
  gem 'bitballoon'
  gem 'jwt', '< 1.5.3', platforms: :mri_19
end

group :puppet_forge do
  gem 'json_pure'
  gem 'puppet'
  gem 'puppet-blacksmith'
end

group :packagecloud do
  gem 'json_pure'
  gem 'packagecloud-ruby', '= 0.2.17'
end

group :testfairy do
  gem 'multipart-post'
end

group :chef_supermarket do
  gem 'chef'
end

group :deis do
  gem 'git'
end

group :opsworks do
  gem 'aws-sdk', '~> 2.6.32'
end

group :qingstor do
  gem 'qingstor-sdk', '= 1.9.3'
end
