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
        if @options[:api_key]
          unless context.shell "mkdir -p ~/.config/scalingo"
            error "Couldn't create authentication file."
          end
          url = URI.parse('http://api.scalingo.com/v1/users/self')
          http = Net::HTTP.new(url.host, url.port)
          request = Net::HTTP::Get.new(url.request_uri)
          request.basic_auth("", @options[:api_key])
          request["Accept"] = "application/json"
          request["Content-type"] = "application/json"
          response = http.request(request)
          data = {}
          if File.exist?("#{Dir.home}/.config/scalingo/auth")
            data = JSON.parse(File.read("#{Dir.home}/.config/scalingo/auth"))
          end
          begin
            user = JSON.parse(response.body)
          rescue
            error "Invalid API token."
          end
          data["auth_config_data"] = {}
          data["auth_config_data"]["api.scalingo.com"] = {}
          data["auth_config_data"]["api.scalingo.com"]["id"] = user["user"]["id"]
          data["auth_config_data"]["api.scalingo.com"]["last_name"] = user["user"]["last_name"]
          data["auth_config_data"]["api.scalingo.com"]["username"] = user["user"]["username"]
          data["auth_config_data"]["api.scalingo.com"]["email"] = user["user"]["email"]
          data["auth_config_data"]["api.scalingo.com"]["first_name"] = user["user"]["first_name"]
          data["auth_config_data"]["api.scalingo.com"]["auth_token"] = @options[:api_key]
          data["last_update"] = DateTime.now
          f = File.open("#{Dir.home}/.config/scalingo/auth", "w+") {
            |f| f.write(data.to_json)
          }
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
