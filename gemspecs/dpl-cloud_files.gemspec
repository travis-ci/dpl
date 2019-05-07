require './gemspec_helper'

# https://github.com/fog/fog-rackspace/issues/29
gemspec_for 'cloud_files', [['nokogiri', '< 1.10'], ['fog-core', '2.1.0'], ['fog-rackspace']]
