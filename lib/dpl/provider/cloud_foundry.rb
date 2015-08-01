module DPL
  class Provider
    class CloudFoundry < Provider

      def initial_go_tools_install
        context.shell 'wget http://go-cli.s3-website-us-east-1.amazonaws.com/releases/latest/cf-cli_amd64.deb -qO temp.deb && sudo dpkg -i temp.deb'
        context.shell 'rm temp.deb'
      end

      def check_auth
        initial_go_tools_install
        context.shell "cf api #{option(:api)}"
        context.shell "cf login --u #{option(:username)} --p #{option(:password)} --o #{option(:organization)} --s #{option(:space)} #{'--skip-ssl-validation' if options[:skip_ssl_validation]}"
      end

      def check_app
        error 'Application must have a manifest.yml for unattended deployment' unless File.exists? 'manifest.yml'
      end

      def needs_key?
        false
      end

      def push_app
        context.shell "cf push #{manifest}"
        context.shell "cf logout"
      end

      def cleanup
      end

      def uncleanup
      end

      def manifest
        options[:manifest].nil? ? "" : "-f #{options[:manifest]}"
      end
    end
  end
end
