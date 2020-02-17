module Dpl
  module Providers
    class Heroku < Provider
      register :heroku

      abstract

      gem 'faraday', '~> 0.9.2'
      gem 'json'
      gem 'netrc', '~> 0.11.0'
      gem 'rendezvous', '~> 0.1.3'

      env :heroku

      opt '--strategy NAME', 'Heroku deployment strategy', default: 'api', enum: %w(api git)
      opt '--app APP', 'Heroku app name', default: :repo_name
      opt '--log_level LEVEL', internal: true

      msgs login:     'Authenticating ... ',
           restart:   'Restarting dynos ... ',
           validate:  'Checking for app %{app} ... ',
           run_cmd:   'Running command %s ... ',
           success:   'success.',
           api_error: 'API request failed: %s (see %s)'

      URL = 'https://api.heroku.com'

      HEADERS = {
        'Accept': 'application/vnd.heroku+json; version=3',
        'User-Agent': user_agent,
      }

      attr_reader :email

      def login
        print :login
        res = http.get('/account')
        handle_error(res) unless res.success?
        @email = JSON.parse(res.body)["email"]
        info :success
      end

      def validate
        print :validate
        res = http.get("/apps/#{app}")
        handle_error(res) unless res.success?
        info :success
      end

      def restart
        print :restart
        res = http.delete "/apps/#{app}/dynos" do |req|
          req.headers['Content-Type'] = 'application/json'
        end
        handle_error(res) unless res.success?
        info :success
      end

      def run_cmd(cmd)
        print :run_cmd, cmd
        res = http.post "/apps/#{app}/dynos" do |req|
          req.headers['Content-Type'] = 'application/json'
          req.body = { command: cmd, attach: true}.to_json
        end
        handle_error(res) unless res.success?
        rendezvous(JSON.parse(res.body)['attach_url'])
      end

      private

        def http
          @http ||= Faraday.new(url: URL, headers: headers) do |http|
            http.basic_auth(username, password) if username && password
            http.response :logger, logger, &method(:filter) if log_level?
            http.adapter Faraday.default_adapter
          end
        end

        def headers
          return HEADERS.dup if username && password
          HEADERS.merge('Authorization': "Bearer #{api_key}")
        end

        def filter(logger)
          logger.filter(/(.*Authorization: ).*/,'\1[REDACTED]')
        end

        def logger
          super(log_level)
        end

        def handle_error(response)
          body = JSON.parse(response.body)
          error :api_error, body['message'], body['url']
        end

        def rendezvous(url)
          Rendezvous.start(url: url)
        end

        # overwritten in Git, meaningless in Api
        def username; end
        def password; end
    end
  end
end

require 'dpl/providers/heroku/api'
require 'dpl/providers/heroku/git'
