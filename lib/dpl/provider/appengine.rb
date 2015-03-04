module DPL
  class Provider
    class AppEngine < Provider
      experimental "Google App Engine"

      BASE_DIR=Dir.pwd

      def self.install_sdk
        requires 'rubyzip', :load => 'zip'
        Dir.chdir(BASE_DIR) do
          unless File.exists? "google-cloud-sdk.zip"
            $stderr.puts "Downloading Google Cloud SDK"
	    context.shell "wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip"
          end

          context.shell "unzip -o -q google-cloud-sdk.zip"

          $stderr.puts "Installing Google Cloud SDK"
          context.shell "google-cloud-sdk/install.sh --usage-reporting false --path-update false --rc-path=~/.bashrc --bash-completion false --override-components=app"
        end
      end

      install_sdk

      def check_auth
        setup_auth
      end

      def setup_auth
        account = option(:account)
        oauth_token = option(:oauth_token)
        context.shell "gcloud auth activate-refresh-token #{account} #{oauth_token}"
      end

      def needs_key?
        false
      end

      def push_app
        # app.yaml must be at the root of the tree.
        context.shell "gcloud preview app deploy ."
      end
    end
  end
end
