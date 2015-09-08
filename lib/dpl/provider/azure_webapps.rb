module DPL
  class Provider
    class AzureWebApps < Provider
      def config
        {
          "username"     => options[:username] || context.env['AZURE_WA_USERNAME'],
          "password"     => options[:password] || context.env['AZURE_WA_PASSWORD'],
          "site"         => options[:site] || context.env['AZURE_WA_SITE']
        }
      end

      def git_target
        "https://#{config['username']}:#{config['password']}@#{config['site']}.scm.azurewebsites.net:443/#{config['site']}.git"
      end

      def needs_key?
        false
      end

      def check_app
      end

      def check_auth
        error "missing Azure Git Deployment username" unless config['username']
        error "missing Azure Git Deployment password" unless config['password']
        error "missing Azure Web App name" unless config['site']
      end

      def push_app
        log "Deploying to Azure Web App '#{config['site']}'"

        if !!options[:verbose]
          context.shell "git push --force --quiet #{git_target} master"
        else
          context.shell "git push --force --quiet #{git_target} master > /dev/null 2>&1"
        end
      end
    end
  end
end
