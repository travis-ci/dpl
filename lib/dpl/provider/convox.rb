# frozen_string_literal: true

module DPL
  class Provider
    class Convox < Provider
      def needs_key?
        false
      end

      def install_url
        options[:install_url] || 'https://convox.com/cli/linux/convox'
      end

      def update_cli
        options[:update_cli] || false
      end

      def convox_gen
        options[:generation] || '2'
      end

      def convox_cli
        './convox'
      end

      def convox_host
        options[:host] || 'console.convox.com'
      end

      def convox_pass
        error 'Console/Rack password required.' if options[:password].nil?
        options[:password]
      end

      def cli_vars
        {
          CONVOX_HOST: convox_host,
          CONVOX_PASSWORD: convox_pass
        }
      end

      def convox_promote
        unless options[:promote].nil?
          return options[:promote]
        end

        # Default
        true
      end

      def convox_exec(cmd)
        cli_vars.each do |k,v|
          ENV[k.to_s] = v
        end
        context.shell "#{convox_cli} #{cmd}"
      end

      def convox_deploy
        unless convox_exec "deploy --rack #{option(:rack)} --app #{option(:app)} --wait --id"
          error 'Convox application deployment failed'
        end
      end

      # Pre-Install
      def install_deploy_dependencies
        context.shell "curl -sL #{install_url} -o #{convox_cli} && chmod 0755 #{convox_cli}"
        context.shell "#{convox_cli} update" if update_cli
      end

      # Required methods (in order of execution)
      def check_auth
        error 'Login failed.' unless convox_exec "version --rack #{option(:rack)}"
      end

      def check_app
        unless convox_exec "apps info --rack #{option(:rack)} --app #{option(:app)}"
          log 'Application doesn\'t exist. Creating a new one.'
          # Create new app and wait
          convox_exec "apps create #{option(:app)} --generation #{convox_gen} --rack #{option(:rack)} --wait"
        end
      end

      def push_app
        if convox_promote
          log "Building and promoting application"
          convox_deploy
        else
          log "Building application only"
          convox_build
        end
      end
    end
  end
end
