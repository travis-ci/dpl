require 'json'
require 'aws-sdk'

module Dpl
  module Providers
    class CodeDeploy < Provider
      # split this up to CodeDeploy::Github and CodeDeploy::S3 using the
      # revision_type, in order to make opts more strict
      summary 'CodeDeploy deployment provider'

      description <<~str
        tbd
      str

      env :aws

      opt '--access_key_id ID', 'AWS access key', required: true
      opt '--secret_access_key KEY', 'AWS secret access key', required: true
      opt '--application NAME', 'CodeDeploy application name', required: true
      opt '--deployment_group GROUP', 'CodeDeploy deployment group name'
      opt '--revision_type TYPE', 'CodeDeploy revision type', enum: %w(s3 or github), downcase: true
      opt '--commit_id SHA', 'Commit ID in case of GitHub'
      opt '--repository NAME', 'Repository name in case of GitHub'
      opt '--bucket NAME', 'S3 bucket in case of S3'
      opt '--region REGION', 'AWS availability zone', default: 'us-east-1'
      opt '--wait_until_deployed', 'Wait until the deployment has finished'
      # mentioned in both the code and the docs
      opt '--bundle_type TYPE'
      opt '--endpoint ENDPOINT'
      opt '--key KEY'
      # mentioned only in the code
      opt '--description DESCR'

      CMDS = {
      }

      ASSERT = {
      }

      MSGS = {
        deploy_triggered:      'Deployment triggered: %s',
        register_revision:     'Registering app revision with version=%s, etag=%s',
        waiting_for_deploy:    'Waiting for the deployment to finish ',
        finished_deploy:       'done: %s.',
        description:           'Deploy build %s via Travis CI',
        missing_bucket:        'Missing required bucket for S3 deployment',
        missing_key:           'Missing required key for S3 deployment',
        unknown_revision_type: 'Unknown revision type %p',
        unknown_bundle_type:   'Unknown bundle type'
      }

      def check_auth
        info "Using Access Key: #{obfuscate(access_key_id)}"
      end

      def deploy
        register_revision if revision_info[:version]
        id = create_deployment
        info :deploy_triggered, id
        wait_until_deployed(id) if wait_until_deployed?
      rescue Aws::CodeDeploy::Errors::DeploymentLimitExceededException => e
        error e.message
      end

      def register_revision
        info :register_revision, revision_info[:version], revision_info[:e_tag]
        code_deploy.register_application_revision(
          revision: revision,
          application_name: application,
          description: description
        )
      end

      def create_deployment
        deployment = code_deploy.create_deployment(
          revision: revision,
          application_name: application,
          deployment_group_name: deployment_group,
          description: description
        )
        deployment.deployment_id
      end

      def wait_until_deployed(id)
        print :waiting_for_deploy
        status = poll(id) until %w(Succeeded Failed Stopped).include?(status)
        info :finished_deploy, status
      end

      def poll(id)
        sleep 5
        print '.'
        code_deploy.get_deployment(deployment_id: id)[:deployment_info][:status]
      end

      def revision_info
        revision[:s3_location] || {}
      end

      def revision
        @revision ||= case revision_type
        when 's3'     then s3_revision
        when 'github' then github_revision
        when nil      then bucket? ? s3_revision : github_revision
        else error :unknown_revision_type, revision_type
        end
      end

      def s3_revision
        {
          revision_type: 'S3',
          s3_location: compact(
            bucket: bucket,
            bundle_type: bundle_type,
            version: revision_version_info[:version_id],
            e_tag: revision_version_info[:etag],
            key: key,
          )
        }
      end

      def revision_version_info
        s3.head_object(bucket: bucket, key: key)
      rescue Aws::Errors::ServiceError => e
        error e.message
      end

      def github_revision
        {
          revision_type: 'GitHub',
          git_hub_location: {
            commit_id:  commit_id,
            repository: repository
          }
        }
      end

      def commit_id
        super || sha
      end

      def repository
        super || ENV['TRAVIS_REPO_SLUG'] || File.basename(Dir.pwd)
      end

      def bucket
        super || error(:missing_bucket)
      end

      def key
        super || error(:missing_key)
      end

      def bundle_type
        super || key =~ /\.(tar|tgz|zip)$/ && $1 || error(:unknown_bundle_type)
      end

      def description
        super || MSGS[:description] % ENV['TRAVIS_BUILD_NUMBER']
      end

      def code_deploy
        @code_deploy ||= Aws::CodeDeploy::Client.new(client_options)
      end

      def s3
        @s3 ||= Aws::S3::Client.new(client_options)
      end

      def client_options
        compact(region: region, credentials: credentials, endpoint: endpoint)
      end

      def credentials
        Aws::Credentials.new(access_key_id, secret_access_key)
      end
    end
  end
end
