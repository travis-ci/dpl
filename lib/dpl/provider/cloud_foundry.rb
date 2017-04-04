module DPL
  class Provider
    class CloudFoundry < Provider
      def check_auth
        initial_go_tools_install
        context.shell "./cf api #{option(:api)} #{'--skip-ssl-validation' if options[:skip_ssl_validation]}"
        context.shell "./cf login -u #{option(:username)} -p #{option(:password)} -o #{option(:organization)} -s #{option(:space)}"
      end

      def check_app
        if options[:manifest]
          error 'Application must have a manifest.yml for unattended deployment' unless File.exists? options[:manifest]
        end
        if options[:zero_downtime] && !app_name
          error 'Application name must be specified for zero-downtime deployment'
        end
      end

      def needs_key?
        false
      end

      def push_app
        if options[:zero_downtime]
          install_autopilot
          context.shell "./cf zero-downtime-push #{app_name}#{manifest}"
        else
          context.shell "./cf push#{manifest}"
        end
        context.shell "./cf logout"
      end

      def cleanup
      end

      def uncleanup
      end

      private

      def initial_go_tools_install
        context.shell "wget 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github' -qO cf-linux-amd64.tgz && tar -zxvf cf-linux-amd64.tgz && rm cf-linux-amd64.tgz"
      end

      def manifest
        options[:manifest].nil? ? "" : " -f #{options[:manifest]}"
      end

      def install_autopilot
        context.shell "./cf install-plugin https://github.com/contraband/autopilot/releases/download/0.0.3/autopilot-linux"
      end

      def app_name
        options[:app_name]
      end
    end
  end
end
