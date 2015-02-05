require 'open-uri'

module DPL
  class Provider
    class AppEngine < Provider
      experimental "Google App Engine"

      BASE_DIR=Dir.pwd
      GCLOUD_ZIP_URL="https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip"
      GCLOUD_ZIP_FILE="google-cloud-sdk.zip"

      def self.install_sdk
        requires 'rubyzip', :load => 'zip'
        Dir.chdir(BASE_DIR) do
          unless File.exists? GCLOUD_ZIP_FILE
            $stderr.puts "Downloading Google Cloud SDK"
            File.open(GCLOUD_ZIP_FILE, "wb") do |dest|
              open(GCLOUD_ZIP_URL, "rb") do |src|
                dest.write(src.read)
              end
            end
          end

          context.shell "unzip -q google-cloud-sdk.zip"
          #unless File.directory? "google-cloud-sdk"
          #  $stderr.puts "Extracting Google Cloud SDK"
          #  Zip::File.open(GCLOUD_ZIP_FILE) do |file|
          #    file.each do |entry|
          #      entry.extract entry.name
          #    end
          #  end
          #end

          $stderr.puts "Installing Google Cloud SDK"
          context.shell "google-cloud-sdk/install.sh --disable-installation-options --usage-reporting false --path-update false --rc-path=~/.bashrc"
        end
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
        context.shell "gcloud preview app deploy ."
      end
    end
  end
end
