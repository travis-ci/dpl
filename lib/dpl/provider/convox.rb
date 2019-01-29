# frozen_string_literal: true

module DPL
  class Provider
    class Convox < Provider
      def install_url
        options[:install_url] || 'https://convox.com/cli/linux/convox'
      end

      CONVOX_INSTALL_CLI = <<-SHELL.gsub(/^ {8}/, '').strip
        if ! command -v convox &>/dev/null ; then
          mkdir -p $HOME/bin
          export PATH="$HOME/bin:$PATH"

          curl -sL -o $HOME/bin/convox $INSTALL_URL
          chmod +x $HOME/bin/convox
        fi
      SHELL

      def needs_key?
        false
      end


      def update_cli
        options[:update_cli] || false
      end

      def convox_create
        options[:create] || false
      end

      def convox_gen
        options[:generation] || '2'
      end

      def convox_cli
        'convox'
      end

      def convox_host
        options[:host] || context.env['CONVOX_HOST'] || 'console.convox.com'
      end

      def convox_pass
        pwd = options[:password] || context.env['CONVOX_PASSWORD']
        error 'Console/Rack password required.' if pwd.nil?
        pwd
      end

      def cli_vars
        {
          CONVOX_HOST: convox_host,
          CONVOX_PASSWORD: convox_pass
        }
      end

      def convox_promote
        options[:promote] || false
      end

      def build_description
        options[:description] || "Travis job ##{context.env['TRAVIS_BUILD_NUMBER']}/commit #{context.env['TRAVIS_COMMIT']}"
      end

      def convox_exec(cmd)
        cli_vars.each do |k, v|
          ENV[k.to_s] = v
        end
        context.shell "#{convox_cli} #{cmd}"
      end

      def convox_deploy
        unless convox_exec "deploy --rack #{option(:rack)} --app #{option(:app)} --wait --id --description \"#{build_description}\""
          error 'Convox application deployment failed'
        end
      end

      def convox_build
        unless convox_exec "build --rack #{option(:rack)} --app #{option(:app)} --id --description \"#{build_description}\""
          error 'Convox application deployment failed'
        end
      end

      def update_envs
        cenvs = options[:environment] || []
        cenvs = [cenvs] if cenvs.is_a? String
        cenvs.map! { |entry| "'" + entry.gsub(%('), %('"'"')) + "'" }

        convox_exec("env set #{cenvs.join(' ')} --rack #{option(:rack)} --app #{option(:app)} --replace")
      end

      # Disable cleanup - we need our binary
      def cleanup; end

      def uncleanup; end

      # Pre-Install
      def install_deploy_dependencies
        context.shell CONVOX_INSTALL_CLI
        context.shell "#{convox_cli} update" if update_cli
      end

      # Required methods (in order of execution)
      def check_auth
        error 'Login failed.' unless convox_exec "version --rack #{option(:rack)}"
      end

      def check_app
        unless convox_exec "apps info --rack #{option(:rack)} --app #{option(:app)}"
          log 'Application doesn\'t exist.'
          # Create new app and wait
          if convox_create
            log "Creating new application #{option(:app)} on rack #{option(:rack)}"
            convox_exec "apps create #{option(:app)} --generation #{convox_gen} --rack #{option(:rack)} --wait"
          else
            error 'Cannot deploy to inexistent app.'
          end
        end
      end

      def push_app
        update_envs if options[:environment]

        if convox_promote
          log 'Building and promoting application'
          convox_deploy
        else
          log 'Building application only'
          convox_build
        end
      end
    end
  end
end
