module DPL
  class Provider
    class AppEngine < Provider
      def self.install_sdk
        $stderr.puts "Installing Cloud SDK"
	context.shell "curl https://sdk.cloud.google.com | bash"
      end

      install_sdk

      def setup_auth
        context.shell "gcloud auth activate-refresh-token option(:oauth_token)"
      end

      def needs_key?
        false
      end

      def push_app
        # app.yaml must be at the root of the tree.
        context.shell "gcloud preview app deploy app.yaml"
      end
    end
  end
end
