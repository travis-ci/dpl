require 'net/http'
require 'uri'
require 'json'
require 'date'

module DPL
  class Provider
    class Scalingo < Provider
      def install_deploy_dependencies
        command = 'curl'
        command = "#{command} --silent" if !@debug
        command = "#{command} -OL https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz"
        tar_options = 'v' if @debug
        tar_options = "#{tar_options}zxf"
        command = "#{command} && tar -#{tar_options} scalingo_latest_linux_amd64.tar.gz" \
                  ' && mv scalingo_*_linux_amd64/scalingo .' \
                  ' && rm scalingo_latest_linux_amd64.tar.gz' \
                  ' && rm -r scalingo_*_linux_amd64'

        error "Couldn't install Scalingo CLI." if !context.shell command
      end

      def initialize(context, options)
        super
        @options = options
        @remote = options[:remote] || 'scalingo'
        @branch = options[:branch] || 'master'
        @region = options[:region] || 'agora-fr1'
        @timeout = options[:timeout] || '60'
        @debug = !options[:debug].nil?
      end

      def logged_in
        scalingo('login', ['DISABLE_INTERACTIVE=true'])
      end

      def check_auth
        token = @options[:api_key] || @options[:api_token]
        if token
          scalingo("login --api-token #{token}")
        elsif @options[:username] && @options[:password]
          scalingo('login', [], "echo -e \"#{@options[:username]}\n#{@options[:password]}\"")
        end
        error "Couldn't connect to Scalingo API to check authentication." if !logged_in
      end

      def setup_key(file, _type = nil)
        error "Couldn't connect to Scalingo API to setup the SSH key." if !logged_in
        error "Couldn't add SSH key." if !scalingo("keys-add dpl_tmp_key #{file}")
      end

      def remove_key
        error "Couldn't connect to Scalingo API to remove the SSH key." if !logged_in
        error "Couldn't remove SSH key." if !scalingo('keys-remove dpl_tmp_key')
      end

      def push_app
        install_deploy_dependencies

        if @options[:app]
          if !scalingo("--app #{@options[:app]} git-setup --remote #{@remote}")
            error 'Failed to add the Git remote.'
          end
        end

        if !context.shell "git push #{@remote} #{@branch} -f"
          error "Couldn't push your app."
        end
      end

      def scalingo(command, env = [], input = '')
        env << "SCALINGO_REGION=#{@region}" if !@region.empty?

        if @debug
          env << 'DEBUG=1'
        else
          command += ' > /dev/null'
        end
        command = "#{input} | #{command}" if input != ''
        command = "#{env.join(' ')} timeout #{@timeout} ./scalingo #{command}"

        puts "Execute #{command}" if @debug

        context.shell command
      end
    end
  end
end
