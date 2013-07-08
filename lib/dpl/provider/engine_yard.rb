module DPL
  class Provider
    class EngineYard < Provider
      experimental "Engine Yard"

      requires 'engineyard'
      requires 'engineyard-cloud-client'

      def token
        options[:api_key] ||= if options[:email] and options[:password]
          EY::CloudClient.authenticate(options[:email], options[:password])
        else
          option(:api_key) # will raise
        end
      end

      def api
        @api ||= EY::CloudClient.new(token, EY::CLI::UI.new)
      end

      def check_auth
        log "authenticated as %s" % api.current_user.email
      end

      def check_app
        @app = EY::CloudClient::App.all(api).detect do |app|
          app.name == option(:app)
        end
      end

      def setup_key(file)
        @key = EY::CloudClient::Keypair.create(api, {
          "name"       => option(:key_name),
          "public_key" => File.read(file)
        })
      end

      def remove_key
        @key.destroy if @key
      end

      def push_app
        fail
        EY::CloudClient::Deployment.deploy(api, option(:environment), deploy_args)
      end

      def deploy_args
        deploy_args = { :ref => `git log --format="%H" -1`.chop }
        if options[:run]
          deploy_args[:migrate]         = true
          deploy_args[:migrate_command] = Array(options[:run]).map { |c| "(#{c})" }.join(" && ")
        elsif options.include? :migrate
          deploy_args[:migrate]         = options[:migrate]
        end
        deploy_args
      end

      def run(command)
        # commands run by deployment
      end

      def deploy
        super
      rescue EY::Error => error
        raise Error, error.message, error.backtrace
      end
    end
  end
end
