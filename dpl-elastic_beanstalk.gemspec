require './gemspec_helper'

gemspec_for 'elastic_beanstalk', [
  ['aws-sdk-core', '~> 3.0'],
  ['aws-sdk-s3', '~> 1.0'],
  ['aws-sdk-elasticbeanstalk', '~> 1.0'],
  ['rubyzip']
]
