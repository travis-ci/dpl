# frozen_string_literal: true

module Dpl
  module Providers
    class Opsworks < Provider
      register :opsworks

      status :stable

      full_name 'AWS OpsWorks'

      description sq(<<-STR)
        tbd
      STR

      gem 'nokogiri', '~> 1.15'
      gem 'aws-sdk-opsworks', '~> 1.0'

      env :aws, :opsworks
      config '~/.aws/credentials', '~/.aws/config', prefix: 'aws'

      opt '--access_key_id ID', 'AWS access key id', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret key', required: true, secret: true
      opt '--app_id APP', 'The app id', required: true
      opt '--region REGION', 'AWS region', default: 'us-east-1'
      opt '--instance_ids ID', 'An instance id', type: :array
      opt '--layer_ids ID', 'A layer id', type: :array
      opt '--migrate', 'Migrate the database.'
      opt '--wait_until_deployed', 'Wait until the app is deployed and return the deployment status.'
      opt '--update_on_success', 'When wait-until-deployed and updated-on-success are both not given, application source is updated to the current SHA. Ignored when wait-until-deployed is not given.', alias: :update_app_on_success
      opt '--custom_json JSON', 'Custom json options override (overwrites default configuration)'

      msgs login: 'Using Access Key: %{access_key_id}',
           create_deploy: 'Creating deployment ... ',
           done: 'Done: %s',
           waiting: 'Deploying ',
           failed: 'Failed.',
           success: 'Success.',
           update_app: 'Updating application source branch/revision setting.',
           app_not_found: 'App %s not found.',
           timeout: 'Timeout: failed to finish deployment within 10 minutes.',
           service_error: 'Deployment failed. OpsWorks service error: %s',
           comment: 'Deploy build %{build_number} via Travis CI'

      def login
        info :login
      end

      def deploy
        timeout(600) { create_deployment }
      rescue Aws::Errors::ServiceError => e
        error :service_error, e.message
      end

      def create_deployment
        print :create_deploy
        id = opsworks.create_deployment(deploy_config)[:deployment_id]
        info :done, id
        wait_until_deployed(id) if wait_until_deployed?
      end

      def deploy_config
        compact(
          stack_id:,
          app_id:,
          command: { name: 'deploy' },
          comment:,
          custom_json:,
          instance_ids:,
          layer_ids:
        )
      end

      def wait_until_deployed(id)
        print :waiting
        depl = poll_deployment(id) while depl.nil? || depl[:status] == 'running'
        error :failed if depl[:status] != 'successful'
        info :success
        update_app if update_on_success?
      end

      def poll_deployment(id)
        print '.'
        sleep 5
        describe_deployments(id)[:deployments].first
      end

      def update_app
        info :update_app
        opsworks.update_app(update_config)
      end

      def update_config
        {
          app_id:,
          app_source: {
            revision: git_sha
          }
        }
      end

      def custom_json
        super || { deploy: { app[:shortname] => { migrate: migrate?, scm: { revision: git_sha } } } }.to_json
      end

      def stack_id
        app[:stack_id]
      end

      def app
        @app ||= describe_app
      end

      def comment
        interpolate(msg(:comment))
      end

      def build_number
        super || sha
      end

      def describe_app
        data = opsworks.describe_apps(app_ids: [app_id])
        error :app_not_found, app_id unless data[:apps]&.any?
        data[:apps].first
      end

      def describe_deployments(id)
        opsworks.describe_deployments(deployment_ids: [id])
      end

      def opsworks
        @opsworks ||= Aws::OpsWorks::Client.new(region:, credentials:)
      end

      def credentials
        Aws::Credentials.new(access_key_id, secret_access_key)
      end

      def timeout(sec, &block)
        Timeout.timeout(sec, &block)
      rescue Timeout::Error
        error :timeout
      end
    end
  end
end
