module DPL
  class Provider
    class AzureBlob < Provider
      def config
        {
          "accessKey" => options[:accessKey] || context.env['AZURE_BLOB_ACCESS_KEY'],
          "sourceDir" => options[:source] || context.env['AZURE_BLOB_SOURCE_DIR'] || '/',
          "destinationUrl" => options[:container] || context.env['AZURE_BLOB_DESTINATION_URL']
        }
      end

      def install_deploy_dependencies
        context.shell "wget -O azcopy.tar.gz https://aka.ms/downloadazcopyprlinux | tar -xf azcopy.tar.gz | ./install.sh"
      end

      def git_target
        "https://#{config['username']}:#{config['password']}@#{config['slot'] || config['site']}.scm.azurewebsites.net:443/#{config['site']}.git"
      end

      def needs_key?
        false
      end

      def check_app
      end

      def check_auth
        error "missing Azure Blob Storage Access Key" unless config['accessKey']
        error "missing Azure Blob Destination URL" unless config['destinationUrl']
      end

      def push_app
        log "Deploying to Azure Blob Storage '#{config['destinationUrl']}'"

        if !!options[:verbose]
          context.shell "azcopy --source #{config['sourceDir']} --destination ${config['destinationUrl']} --dest-key ${config['accessKey']} --recursive --quiet --set-content-type"
        else
          context.shell "azcopy --source #{config['sourceDir']} --destination ${config['destinationUrl']} --dest-key ${config['accessKey']} --recursive --quiet --set-content-type > /dev/null 2>&1"
        end
      end
    end
  end
end
