require 'json/pure'
require 'puppet/face'
require 'puppet_blacksmith'

module DPL
  class Provider
    class PuppetForge < Provider
      require 'pathname'

      def modulefile
        @modulefile ||= Blacksmith::Modulefile.new
      end

      def forge
        @forge ||= Blacksmith::Forge.new(options[:user], options[:password], options[:url])
      end

      def build
        pmod = Puppet::Face['module', :current]
        pmod.build('./')
      end

      def needs_key?
        false
      end

      def check_app
        modulefile.metadata
      end

      def check_auth
        raise Error, "must supply a user" unless option(:user)
        raise Error, "must supply a password" unless option(:password)
      end

      def push_app
        build
        log "Uploading to Puppet Forge #{forge.username}/#{modulefile.name}"
        forge.push!(modulefile.name)
      end
    end
  end
end
