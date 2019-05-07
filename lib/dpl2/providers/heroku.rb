require 'faraday'
require 'json'

module Dpl
  module Providers
    class Heroku < Provider
      summary 'Heroku deployment provider'

      description <<~str
        tbd
      str

      required :api_key, [:username, :password]

      # move sub cmd specific opts to the sub command
      opt '--api_key KEY', 'Heroku API key'
      opt '--strategy NAME', 'Deployment strategy', default: 'api', enum: %w(api git)
      opt '--app APP', 'Heroku app name', default: :repo_name
      # according to the docs it should be --username, but the code uses --user
      # https://github.com/travis-ci/dpl/blob/master/lib/dpl/provider/heroku/generic.rb#L20
      opt '--username USER', 'Heroku username', alias: :user
      opt '--password PASS', 'Heroku password'
      # mentioned in the code
      opt '--log_level LEVEL'
      opt '--git URL' # git remote url
      opt '--version VERSION' # used in triggering a build via api, not sure this should be exposed?

      def self.new(ctx, args)
        return super unless registry_key.to_sym == :heroku
        i = args.index('--strategy')
        _, opts = parse(ctx, i ? args[i, 2] : [])
        Provider[:"heroku:#{opts[:strategy]}"].new(ctx, args)
      end

      URL = 'https://api.heroku.com'

      HEADERS = {
        'Accept': 'application/vnd.heroku+json; version=3',
        'User-Agent': user_agent,
      }

      attr_reader :email

      def login
        print 'Authenticating ... '
        res = http.get('/account')
        handle_error(res) unless res.success?
        @email = JSON.parse(res.body)["email"]
        info 'success.'
      end

      def validate
        print "Checking for app #{app} ... "
        res = http.get("/apps/#{app}")
        handle_error(res) unless res.success?
        info 'success.'
      end

      def restart
        print 'Restarting dynos ... '
        res = http.delete "/apps/#{app}/dynos" do |req|
          req.headers['Content-Type'] = 'application/json'
        end
        handle_error(res) unless res.success?
        info 'success.'
      end

      def run_cmd(cmd)
        print "Running command #{cmd} ... "
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
          return HEADERS.dup unless username && password
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
          error "API request failed.\nMessage: #{body['message']}\nReference: #{body['url']}"
        end
    end
  end
end

require 'dpl2/providers/heroku/api'
require 'dpl2/providers/heroku/git'
