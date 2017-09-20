module DPL
  class Provider
    class Convox < Provider

      def install_deploy_dependencies
        error "Couldn't install Convox CLI" unless context.shell "sudo start-docker-daemon && curl -O https://bin.equinox.io/c/jewmwFCp7w9/convox-stable-linux-amd64.tgz && sudo tar zxvf convox-stable-linux-amd64.tgz -C /usr/local/bin && rm convox-stable-linux-amd64.tgz"
      end

      def check_auth
        error "Must supply console_key option" unless options[:console_key]
        console_host = options[:console_host].nil? ? "console.convox.com" : options[:console_host]
        context.shell "convox login #{console_host} --password #{options[:console_key]}"
      end

      def check_app
        error "Must supply app option" unless options[:app]
        error "Must supply rack option" unless options[:rack]
      end

      def needs_key?
        false
      end

      def cleanup
      end

      def uncleanup
      end

      def push_app
        deploy_cmd = "convox deploy --app #{options[:app]} --rack #{options[:rack]}"
        deploy_cmd << " --description #{options[:description]}" if options[:description]
        error "Failed to deploy app" unless context.shell deploy_cmd

        if options[:copy_to_app]
          copy_to_rack = options[:copy_to_rack].nil? ? options[:rack] : options[:copy_to_rack]
          copy_cmd = "convox builds export $(convox builds --app #{options[:app]} --rack #{options[:rack]}"
          copy_cmd << " | awk 'NR==2 {print $1}') --app #{options[:app]} --rack #{options[:rack]}"
          copy_cmd << " | convox builds import --app #{options[:copy_to_app]} --rack #{copy_to_rack}"
          context.shell copy_cmd
        end
      end

    end
  end
end
