module DPL
  class Provider
    module Heroku
      class Generic < Provider
        requires 'heroku-api'
        requires 'rendezvous'

        def needs_key?
          false
        end

        def api
          @api ||= ::Heroku::API.new(:api_key => option(:api_key)) unless options[:user] and options[:password]
          @api ||= ::Heroku::API.new(:user => options[:user], :password => options[:password])
        end

        def user
          @user ||= api.get_user.body["email"]
        end

        def check_auth
          log "authenticated as %s" % user
        end

        def check_app
          log "checking for app '#{option(:app)}'"
          info = api.get_app(option(:app)).body
          log "found app '#{info['name']}'"
        rescue ::Heroku::API::Errors::Forbidden => error
          raise Error, "#{error.message} (does the app '#{option(:app)}' exist and does your account have access to it?)", error.backtrace
        end

        def run(command)
          data           = api.post_ps(option(:app), command, :attach => true).body
          rendezvous_url = data['rendezvous_url']
          Rendezvous.start(:url => rendezvous_url) unless rendezvous_url.nil?
        end

        def restart
          api.post_ps_restart option(:app)
        end

        def deploy
          super
        rescue ::Heroku::API::Errors::NotFound => error
          raise Error, "#{error.message} (wrong app #{options[:app].inspect}?)", error.backtrace
        rescue ::Heroku::API::Errors::Unauthorized => error
          raise Error, "#{error.message} (wrong API key?)", error.backtrace
        end
      end
    end
  end
end
