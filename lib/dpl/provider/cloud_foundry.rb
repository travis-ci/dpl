module DPL
  class Provider
    class CloudFoundry < Provider

      def initial_go_tools_install
        context.shell 'test $(uname) = "Linux" && rel="linux64-binary" || rel="macosx64"; wget "https://cli.run.pivotal.io/stable?release=${rel}&source=github" -qO cf.tgz && tar -zxvf cf.tgz && rm cf.tgz'
      end

      def check_auth
        initial_go_tools_install
        context.shell "./cf api #{option(:api)} #{'--skip-ssl-validation' if options[:skip_ssl_validation]}"
        options[:client_id] ? check_client_auth : check_basic_auth
      end

      def check_app
        if options[:manifest]
          error 'Application must have a manifest.yml for unattended deployment' unless File.exists? options[:manifest]
        end
      end

      def needs_key?
        false
      end

      def push_app
        error 'Failed to push app' unless context.shell("./cf push#{app_name}#{manifest}")

      ensure
        context.shell "./cf logout"
      end

      def cleanup
      end

      def uncleanup
      end

      def app_name
        options[:app_name].nil? ? "" : " '#{options[:app_name]}'"
      end

      def manifest
        options[:manifest].nil? ? "" : " -f #{options[:manifest]}"
      end

      private

      def check_basic_auth
        context.shell "./cf login -u #{option(:username)} -p #{option(:password)} -o '#{option(:organization)}' -s '#{option(:space)}'"
      end

      def check_client_auth
        context.shell "./cf auth #{option(:client_id)} #{option(:client_secret)} --client-credentials"
        context.shell "./cf target -o '#{option(:organization)}' -s '#{option(:space)}'"
      end
    end
  end
end
