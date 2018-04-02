require 'net/http'
require 'uri'
require 'json'
require 'date'

module DPL
  class Provider
    class Scalingo < Provider

      def install_deploy_dependencies
        unless context.shell "curl -OL https://cli-dl.scalingo.io/release/scalingo_latest_linux_amd64.tar.gz && tar -zxvf scalingo_latest_linux_amd64.tar.gz && mv scalingo_*_linux_amd64/scalingo . && rm scalingo_latest_linux_amd64.tar.gz && rm -r scalingo_*_linux_amd64"
          error "Couldn't install Scalingo CLI."
        end
      end

      def initialize(context, options)
        super
        @options = options
        @remote = options[:remote] || "scalingo"
        @branch = options[:branch] || "master"
      end

      def logged_in
        context.shell "DISABLE_INTERACTIVE=true ./scalingo login 2> /dev/null > /dev/null"
      end

      def check_auth
        token = @options[:api_key] || @options[:api_token]
        if token
          context.shell "timeout 2 ./scalingo login --api-token #{token} 2> /dev/null > /dev/null"
        elsif @options[:username] && @options[:password]
          context.shell "echo -e \"#{@options[:username]}\n#{@options[:password]}\" | timeout 2 ./scalingo login 2> /dev/null > /dev/null"
        end
        if !logged_in
          error "Couldn't connect to Scalingo API."
        end
      end

      def setup_key(file, type = nil)
        if !logged_in
          error "Couldn't connect to Scalingo API."
        end
        unless context.shell "./scalingo keys-add dpl_tmp_key #{file}"
          error "Couldn't add ssh key."
        end
      end

      def remove_key
        if !logged_in
          error "Couldn't connect to Scalingo API."
        end
        unless context.shell "./scalingo keys-remove dpl_tmp_key"
          error "Couldn't remove ssh key."
        end
      end

      def push_app
        if @options[:app]
          context.shell "git remote add #{@remote} git@scalingo.com:#{@options[:app]}.git 2> /dev/null > /dev/null"
        end
        unless context.shell "git push #{@remote} #{@branch} -f"
          error "Couldn't push your app."
        end
      end

    end
  end
end
