require 'net/http'
require 'uri'

module Dpl
  module Providers
    class Tsuru < Provider
      status :dev

      description sq(<<-str)
        tbd
      str

      gem 'json', '~> 2.2.0'

      opt '--email EMAIL',   'Tsuru email', required: true
      opt '--password PASS', 'Tsuru password', required: true
      opt '--server URL',    'Tsuru server address', required: true
      opt '--app NAME',      'Tsuru app name', default: :repo_name
      opt '--refspec STR',   'Git refspec to push', default: 'HEAD:master'
      # TODO change Cl to allow :default to take a proc, so we can make this 'dpl_:{repo_name}_deploy_key'
      opt '--key_name NAME', 'SSH deploy key name to add to Tsuru', default: 'dpl_deploy_key'

      needs :ssh_key

      msgs login:  'Authenticated as %{email}',
           app:    'Found app %{app}'

      cmds deploy: 'git push --force %{repo} %{refspec}'

      PATHS = {
        login:      '/auth/login',
        app:        '/apps/%{app}',
        add_key:    '/users/keys',
        remove_key: '/users/keys/%{key_name}'
      }

      attr_reader :repo, :user

      def login
        @user = post :login, email: email, password: password
        msg :login
      end

      def add_key(path)
        post :add_key, { name: key_name, key: read(path).chomp }, headers
      end

      def validate
        app = get :app, headers
        @repo = app['repository'] # does the repo name contain secrets? can we log it?
        info :app
      end

      def deploy
        shell :deploy
      end

      def remove_key
        delete :remove_key, headers
      end

      private

        def post(path, body, headers = nil)
          request(:post, path, headers) { |req| req.set_form_data(body) }
        end

        def get(path, headers)
          request(:get, path, headers)
        end

        def delete(path, headers)
          request(:delete, path, headers)
        end

        def request(method, path, headers)
          path = interpolate(PATHS[path])
          req = Net::HTTP.const_get(method.capitalize).new(path, headers)
          yield req if block_given?
          res = http.request(req)
          JSON.parse(res.body) if res.body && res.body.length >= 2
        end

        def headers
          {
            'Authorization' => "Bearer #{user['token']}",
            'Content-Type'  => 'application/x-www-form-urlencoded'
          }
        end

        def http
          @http ||= Net::HTTP.new(server.host, server.port)
        end

        def server
          URI.parse(super)
        end
    end
  end
end
