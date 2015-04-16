source 'https://rubygems.org'
gemspec

platforms :mri_19 do
  gem 'slop', '~> 3.6.0'
  gem 'ohai', '~> 7.4.0'
end

group :heroku do
  gem 'rendezvous', '~> 0.0.2'
  gem 'heroku-api', '= 0.3.16'
  gem 'anvil-cli', '~> 0.16.1'
  gem 'netrc'
end

group :openshift do
  gem 'rhc'
  gem 'httpclient'
end

group :appfog do
  gem 'af'
end

group :rubygems do
  gem 'gems'
end

group :sss do
  gem 'aws-sdk', '>= 2.0.18.pre'
  gem 'mime-types'
end

group :code_deploy do
  gem 'aws-sdk', '>= 2.0.18.pre'
end

group :lambda do
  gem 'aws-sdk', '>= 2.0.18.pre'
  gem 'rubyzip'
end

group :cloud_files do
  gem 'fog'
end

group :releases do
  gem 'octokit'
end

group :gcs do
  gem 'gstore'
  gem 'mime-types'
end

group :gae do
  gem 'rubyzip'
end

group :elastic_beanstalk do
  gem 'rubyzip'
  gem 'aws-sdk-v1'
end

group :bitballoon do
  gem 'bitballoon'
end

group :puppet_forge do
  gem 'puppet'
  gem 'puppet-blacksmith'
end

group :packagecloud do
  gem 'packagecloud-ruby', '= 0.2.17'
end

group :testfairy do
  gem 'multipart-post'
end

group :chef_supermarket do
  gem 'chef'
end
