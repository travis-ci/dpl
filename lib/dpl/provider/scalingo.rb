require 'net/http'
require 'uri'
require 'json'
require 'date'

module DPL
  class Provider
    class Scalingo < Provider
      def install_deploy_dependencies
        download_url = 'https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz'
        command = 'curl'
        command = "#{command} --silent" if !@debug
        command = "#{command} --remote-name --location #{download_url}"
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

      def check_auth
        token = @options[:api_key] || @options[:api_token]
        if token
          scalingo("login --api-token #{token}")
        elsif @options[:username] && @options[:password]
          scalingo('login', [], "echo -e \"#{@options[:username]}\n#{@options[:password]}\"")
        end
      end

      def setup_key(file, _type = nil)
        if !scalingo("keys-add dpl_tmp_key #{file}")
          error "Couldn't add SSH key."
        end
      end

      def remove_key
        if !scalingo('keys-remove dpl_tmp_key')
          error "Couldn't remove SSH key."
        end
      end

      def push_app
        install_deploy_dependencies

        if @options[:app]
          if !scalingo("--app #{@options[:app]} git-setup --remote #{@remote}")
            error 'Failed to add the Git remote.'
          end
        end

        if !context.shell "git push #{@remote} #{@branch} --force"
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
        command = "#{env.join(' ')} timeout #{@timeout} ./scalingo #{command}"
        command = "#{input} | #{command}" if input != ''

        puts "Execute #{command}" if @debug

        context.shell command
      end
    end
  end
end
