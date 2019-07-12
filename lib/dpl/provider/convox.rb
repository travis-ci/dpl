# frozen_string_literal: true

require 'json'
require 'shellwords'

module DPL
  class Provider
    class Convox < Provider
      def install_url
        options[:install_url] || 'https://convox.com/cli/linux/convox'
      end

      def convox_install_cli
        <<-SHELL.gsub(/^ {10}/, '').strip
          if ! command -v convox &>/dev/null ; then
            echo "Downloading convox CLI"
            mkdir -p $HOME/bin
            export PATH="$HOME/bin:$PATH"

            curl -sL -o $HOME/bin/convox #{install_url}
            chmod +x $HOME/bin/convox
          else
            echo "Convox CLI exists. Skipping installation"
          fi
        SHELL
      end

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
          CONVOX_PASSWORD: convox_pass,
          CONVOX_APP: option(:app),
          CONVOX_RACK: option(:rack),
          CONVOX_CLI: convox_cli
        }
      end

      def convox_promote
        return true if options[:promote].nil?

        options[:promote].to_s == 'true'
      end

      def build_description
        commit_author = `git log -1 #{context.env['TRAVIS_COMMIT']} --pretty="%aN"`.strip

        desc = {
          repo_slug: context.env['TRAVIS_REPO_SLUG'],
          travis_build_id: context.env['TRAVIS_BUILD_ID'],
          travis_build_number: context.env['TRAVIS_BUILD_NUMBER'],
          git_commit_sha: context.env['TRAVIS_COMMIT'],
          git_commit_message: context.env['TRAVIS_COMMIT_MESSAGE'],
          git_commit_author: commit_author,
          git_tag: context.env['TRAVIS_TAG'],
          branch: context.env['TRAVIS_BRANCH'],
          pull_request: context.env['TRAVIS_PULL_REQUEST']
        }
        options[:description] || desc.to_json
      end

      def setenvs
        cli_vars.each do |k, v|
          ENV[k.to_s] = v
        end
      end

      def convox_exec(cmd)
        context.shell "#{convox_cli} #{cmd}"
      end

      def convox_deploy
        unless convox_exec "deploy --rack #{option(:rack)} --app #{option(:app)} --wait --id --description #{Shellwords.escape(build_description)}"
          error 'Convox application deployment failed'
        end
      end

      def convox_build
        unless convox_exec "build --rack #{option(:rack)} --app #{option(:app)} --id --description #{Shellwords.escape(build_description)}"
          error 'Convox application deployment failed'
        end
      end

      def env_file
        return nil unless options[:env_file]

        # Read from env_file
        env_map = []

        # Check if file exists
        error 'env_file doesn\'t exist' unless File.exist?(options[:env_file])
        # Read file
        File.open(options[:env_file]) do |file|
          file.each do |line|
            # Parse envs to dict and add to env_map
            env_map.push(line.chomp) unless line.chomp.empty?
          end
        end

        env_map
      end

      def environment
        return nil unless env_file || options[:env]

        cenvs = env_file || []

        yenvs = options[:env] || []
        yenvs = [yenvs] if yenvs.is_a? String

        cenvs.concat yenvs

        cenvs.map! do |entry|
          entry += '=' + (context.env[entry] || '') unless entry.include?('=')

          "'" + entry.gsub(%('), %('"'"')) + "'"
        end
      end

      def update_envs
        convox_exec("env set #{environment.join(' ')} --rack #{option(:rack)} --app #{option(:app)} --replace")
      end

      # Disable cleanup - we need our binary
      def cleanup; end

      def uncleanup; end

      # Pre-Install
      def install_deploy_dependencies
        context.shell convox_install_cli
        context.shell "#{convox_cli} update" if update_cli
      end

      # Required methods (in order of execution)
      def check_auth
        error 'Login failed.' unless convox_exec "version --rack #{option(:rack)}"
      end

      def check_app
        setenvs # Set CONVOX_* envs for deployment process
        unless convox_exec "apps info --rack #{option(:rack)} --app #{option(:app)}"
          log 'Application doesn\'t exist.'
          # Create new app and wait
          if convox_create
            log "Creating new application #{option(:app)} on rack #{option(:rack)}"
            convox_exec "apps create #{option(:app)} --generation #{convox_gen} --rack #{option(:rack)} --wait"
          else
            error 'Cannot deploy to inexisting app.'
          end
        end
      end

      def run(command)
        cli_vars.each do |k, v|
          ENV[k.to_s] = v
        end
        error 'Running command failed.' unless context.shell command.to_s
      end

      def push_app
        update_envs unless environment.nil?

        Array(options[:before_deploy]).each do |command|
          context.fold(format('Running %p', command)) { run(command) }
        end

        if convox_promote
          context.fold('Building and promoting application') { convox_deploy }
        else
          context.fold('Building application only') { convox_build }
        end

        Array(options[:after_deploy]).each do |command|
          context.fold(format('Running %p', command)) { run(command) }
        end
      end
    end
  end
end
