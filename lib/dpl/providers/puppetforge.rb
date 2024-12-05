# frozen_string_literal: true

module Dpl
  module Providers
    class Puppetforge < Provider
      register :puppetforge

      status :alpha

      full_name 'Puppet Forge'

      description sq(<<-STR)
        tbd
      STR

      gem 'racc', '~> 1.7'
      gem 'puppet', '~> 7.25', require: 'puppet/face'
      gem 'puppet-blacksmith', '~> 7', require: 'puppet_blacksmith'

      env :puppetforge

      opt '--username NAME', 'Puppet Forge user name', required: true, alias: :user
      opt '--password PASS', 'Puppet Forge password', required: true, secret: true
      opt '--url URL', 'Puppet Forge URL to deploy to', default: 'https://forgeapi.puppetlabs.com/'

      msgs upload: 'Uploading to Puppet Forge %s/%s'

      def validate
        file.metadata
      end

      def deploy
        build
        info :upload, forge.username, file.name
        forge.push!(file.name)
      end

      def file
        @file ||= Blacksmith::Modulefile.new
      end

      def build
        Puppet::Face['module', :current].build('./')
      end

      def forge
        @forge ||= Blacksmith::Forge.new(username, password, url)
      end
    end
  end
end
