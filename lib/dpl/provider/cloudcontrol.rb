require 'json'
require 'net/http'
require 'net/https'

module DPL
  class Provider
    class CloudControl < Provider
      attr_accessor :app_name
      attr_accessor :dep_name

      def initialize(context, options)
        super
        option(:email) && option(:password) && option(:deployment)
        @app_name, @dep_name = options[:deployment].split('/')

        @http = Net::HTTP.new('api.cloudcontrol.com', 443)
        @http.use_ssl = true
      end

      def check_auth
        headers_with_token
      end

      def check_app
        response = api_call('GET', "/app/#{ app_name }/deployment/#{ dep_name }")
        error('application check failed') if response.code != '200'
        @repository = JSON.parse(response.body)["branch"]
      end

      def setup_key(file)
        data = { 'key' => File.read(file).chomp }
        response = api_call('POST', "/user/#{ user['username'] }/key", JSON.dump(data))
        error('adding key failed') if response.code != '200'
        key = JSON.parse response.body
        @ssh_key_id = key['key_id']
      end

      def remove_key
        response = api_call('DELETE', "/user/#{ user['username']}/key/#{ @ssh_key_id }")
        error('key removal failed') if response.code != '204'
      end

      def push_app
        branch = (dep_name == 'default') ? 'master' : dep_name
        context.shell "git push #{ @repository } #{ branch };"
        deploy_app
      end

    private

        def get_token
          request = Net::HTTP::Post.new '/token/'
          request.basic_auth options[:email], options[:password]
          response = @http.request(request)
          error('authorization failed') if response.code != '200'
          return JSON.parse response.body
        end

        def headers_with_token(options = {})
          @token = get_token if options[:new_token] || @token.nil?
          return {
            'Authorization' => %Q|cc_auth_token="#{ @token['token'] }"|,
            'Content-Type' => 'application/json'
          }
        end

        def get_headers
          headers = headers_with_token
          response = api_call('GET', '/user/', nil, headers)
          return headers if response.code == '200'

          return headers_with_token :new_token => true
        end

        def api_call(method, path, data = nil, headers = nil)
          return @http.send_request(method, path, data, headers || get_headers)
        end

        def deploy_app
          data = {'version' => -1}
          response = api_call('PUT', "/app/#{ app_name }/deployment/#{ dep_name }", JSON.dump(data))
          error('deployment failed - the deployment is already deploying') if response.code != '200'
        end

        def user
          if @user.nil?
            response = api_call('GET', '/user/')
            error('can not find the user') if response.code != '200'
            users = JSON.parse response.body
            @user = users[0]
          end
          return @user
        end
    end
  end
end
