require 'engineyard-cloud-client'

# maybe use the cli (https://github.com/engineyard/engineyard) instead, and get
# rid of the runtime gem dependency (also a lot easier to test).

module Dpl
  module Providers
    class EngineYard < Provider
      summary 'EngineYard deployment provider'

      description <<~str
        tbd
      str

      required :api_key, [:email, :password]

      opt '--api_key KEY',     'Engine Yard API key'
      opt '--email EMAIL',     'Engine Yard account email'
      opt '--password PASS',   'Engine Yard password'
      opt '--app APP',         'Engine Yard application name', default: :repo_name
      opt '--environment ENV', 'Engine Yard application environment'
      opt '--migrate CMD',     'Engine Yard migration commands'
      opt '--account NAME'

      MSGS = {
        deploy:          'Deploying ...',
        invalid_migrate: 'Invalid migration command, try --migrate="rake db:migrate"',
        authenticated:   'Authenticated as %s',
        multiple_envs:   "Multiple matches possible, please be more specific: %s",
        env_entry:       'environment=%s account=%s',
        deploy_done:     'Done: https://cloud.engineyard.com/apps/%s/environments/%s/deployments/%s/pretty',
        deploy_failed:   'Deployment failed (see logs on Engine Yard)'
      }

      attr_reader :env, :token

      def login
        info :authenticated, api.current_user.email
      end

      def validate
        @env ||= resolve(envs)
        error :invalid_migrate if invalid_migrate?
      end

      def deploy
        print :deploy
        poll_for_result(deployment).successful || error(:deploy_failed)
      end

      private

        def invalid_migrate?
          migrate.is_a?(TrueClass) || migrate == 'true'
        end

        def authenticate
          @token ||= api_key || EY::CloudClient.new.authenticate!(email, password)
        rescue EY::CloudClient::Error => e
          error e.message
        end

        def api
          @api ||= EY::CloudClient.new(token: token)
        rescue EY::CloudClient::Error => e
          error e.message
        end

        def deployment
          opts = { ref: sha }
          opts = opts.merge(migrate: true, migration_command: migrate) if migrate?
          EY::CloudClient::Deployment.deploy(api, env, opts)
        rescue EY::CloudClient::Error => e
          error e.message
        end

        def envs
          api.resolve_app_environments(
            app_name: app,
            account_name: account,
            environment_name: environment,
            remotes: remotes
          )
        end

        def resolve(envs)
          envs.one_match { return envs.matches.first }
          envs.no_matches { error envs.errors.join("\n").inspect }
          envs.many_matches { |envs| multiple_env_matches(envs) }
        end

        def multiple_env_matches(envs)
          envs = envs.map { |env| MSGS[:env_entry] % [env.environment.name, env.environment.account.name] }
          error MSGS[:multiple_envs] % envs.join(', ')
        end

        def poll_for_result(deployment)
          deployment = refresh(deployment) until deployment.finished?
          info :deploy_done, deployment.app.id, deployment.environment.id, deployment.id
          deployment
        end

        def refresh(deployment)
          sleep 5
          print '.'
          EY::CloudClient::Deployment.get(api, deployment.app_environment, deployment.id)
        end
    end
  end
end
