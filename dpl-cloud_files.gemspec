require './gemspec_helper'

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.3.0")
  gemspec_for 'cloud_files', [['net-ssh'], ['mime-types'], ['nokogiri', '< 1.10'], ['fog-rackspace']]
else
  gemspec_for 'cloud_files', [['net-ssh'], ['mime-types'], ['nokogiri'], ['fog-rackspace']]
end
