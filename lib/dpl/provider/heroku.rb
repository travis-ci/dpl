module DPL
  class Provider
    class Heroku < Provider
      requires 'heroku-api'
      requires 'rendezvous'

      def api
        @api ||= ::Heroku::API.new(:api_key => option(:api_key)) unless options[:user] and options[:password]
        @api ||= ::Heroku::API.new(:user => options[:user], :password => options[:password])
      end

      def check_auth
        log "authenticated as %s" % api.get_user.body["email"]
      end

      def check_app
        info = api.get_app(option(:app)).body
        options[:git] ||= info['git_url']
        log "found app #{info['name']}"
      end

      def setup_key(file)
        api.post_key File.read(file)
      end

      def push_app
        system "git push git@heroku.com:#{option(:app)}.git HEAD:master -f"
      end

      def run(command)
        data           = heroku.post_ps(option(:app), command, :attach => true).body
        rendezvous_url = data['rendezvous_url']
        Rendezvous.start(:url => rendezvous_url) unless rendezvous_url.nil?
      end

      def deploy
        super
      rescue ::Heroku::API::Errors::NotFound=> error
        raise Error, "#{error.message} (wrong app #{options[:app].inspect}?)", error.backtrace
      rescue ::Heroku::API::Errors::Unauthorized => error
        raise Error, "#{error.message} (wrong API key?)", error.backtrace
      end
    end
  end
end
