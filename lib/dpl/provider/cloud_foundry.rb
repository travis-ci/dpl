module DPL
  class Provider
    class CloudFoundry < Provider
      requires 'cf'

      def check_auth
        context.shell "cf target #{option(:target)}"
        context.shell "cf login --username #{option(:username)} --password #{option(:password)} --organization #{option(:organization)} --space #{option(:space)}"
      end

      def check_app
        error 'Application must have a manifest.yml for unattended deployment' unless File.exists? 'manifest.yml'
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "cf push"
        context.shell "cf logout"
      end

      def cleanup
      end

      def uncleanup
      end
    end
  end
end
