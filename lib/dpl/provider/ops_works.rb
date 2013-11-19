module DPL
  class Provider
    class OpsWorks < Provider
      requires 'aws-sdk'
      experimental 'AWS OpsWorks'

      def api
        @api ||= AWS::OpsWorks.new
      end

      def needs_key?
        false
      end

      def check_app

      end

      def setup_auth
        AWS.config(access_key_id: option(:access_key_id), secret_access_key: option(:secret_access_key))
      end

      def check_auth
        setup_auth
        log "Logging in with Access Key: #{option(:access_key_id)[-4..-1].rjust(20, '*')}"
      end

      def push_app
        api.client.create_deployment(stack_id: option(:stack_id), app_id: option(:app_id), command: {name: 'deploy'})
      end

      def deploy
        super
      rescue AWS::Errors::ClientError => error
        raise Error, "Stopping Deploy, OpsWorks error: #{error.message}", error.backtrace
      rescue AWS::Errors::ServerError => error
        raise Error, "Stopping Deploy, OpsWorks server error: #{error.message}", error.backtrace
      end
    end
  end
end
