module DPL
  class Provider
    class OpsWorks < Provider
      requires 'aws-sdk'
      experimental 'AWS OpsWorks'

      def api
        @api ||= AWS::OpsWorks.new
      end

      def client
        @client ||= api.client
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

      def custom_json
        {
          deploy: {
            ops_works_app[:shortname] => {
              migrate: !!options[:migrate],
              scm: {
                revision: current_sha
              }
            }
          }
        }
      end

      def current_sha
        @current_sha ||= `git rev-parse HEAD`.chomp
      end

      def ops_works_app
        @ops_works_app ||= fetch_ops_works_app
      end

      def fetch_ops_works_app
        data = client.describe_apps(app_ids: [option(:app_id)])
        unless data[:apps] && data[:apps].count == 1
          raise Error, "App #{option(:app_id)} not found.", error.backtrace
        end
        data[:apps].first
      end

      def push_app
        data = client.create_deployment(
          stack_id: ops_works_app[:stack_id],
          app_id: option(:app_id),
          command: {name: 'deploy'},
          comment: travis_deploy_comment,
          custom_json: custom_json.to_json
        )
        log "Deployment created: #{data[:deployment_id]}"
      end

      def travis_deploy_comment
        "Deploy #{ENV['TRAVIS_COMMIT'] || current_sha} via Travis CI"
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
