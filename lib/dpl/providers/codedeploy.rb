# frozen_string_literal: true

module Dpl
  module Providers
    # split this up to CodeDeploy::Github and CodeDeploy::S3 using the
    # revision_type, in order to make opts more strict
    class Codedeploy < Provider
      register :codedeploy

      status :stable

      full_name 'AWS Code Deploy'

      description sq(<<-STR)
        tbd
      STR

      gem 'nokogiri', '~> 1.15'
      gem 'aws-sdk-codedeploy', '~> 1.0'
      gem 'aws-sdk-s3', '~> 1'

      env :aws, :codedeploy
      config '~/.aws/credentials', '~/.aws/config', prefix: 'aws'

      opt '--access_key_id ID', 'AWS access key', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret access key', required: true, secret: true
      opt '--application NAME', 'CodeDeploy application name', required: true
      opt '--deployment_group GROUP', 'CodeDeploy deployment group name'
      opt '--revision_type TYPE', 'CodeDeploy revision type', enum: %w[s3 github], downcase: true
      opt '--commit_id SHA', 'Commit ID in case of GitHub'
      opt '--repository NAME', 'Repository name in case of GitHub'
      opt '--bucket NAME', 'S3 bucket in case of S3'
      opt '--region REGION', 'AWS availability zone', default: 'us-east-1'
      opt '--file_exists_behavior STR', 'How to handle files that already exist in a deployment target location', enum: %w[disallow overwrite retain], default: 'disallow'
      opt '--wait_until_deployed', 'Wait until the deployment has finished'
      opt '--bundle_type TYPE', 'Bundle type of the revision'
      opt '--key KEY', 'S3 bucket key of the revision'
      opt '--description DESCR', 'Description of the revision', interpolate: true
      opt '--endpoint ENDPOINT', 'S3 endpoint url'

      msgs login: 'Using Access Key: %{access_key_id}',
           deploy_triggered: 'Deployment triggered: %s',
           register_revision: 'Registering app revision with version=%s, etag=%s',
           waiting_for_deploy: 'Waiting for the deployment to finish ',
           finished_deploy: 'done: %s.',
           description: 'Deploy build %{build_number} via Travis CI',
           missing_bucket: 'Missing required bucket for S3 deployment',
           missing_key: 'Missing required key for S3 deployment',
           unknown_revision_type: 'Unknown revision type %p',
           unknown_bundle_type: 'Unknown bundle type'

      vars :build_number

      def login
        info :login
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
          revision:,
          application_name: application,
          description:
        )
      end

      def create_deployment
        deployment = code_deploy.create_deployment(
          revision:,
          application_name: application,
          deployment_group_name: deployment_group,
          description:,
          file_exists_behavior: file_exists_behavior.upcase
        )
        deployment.deployment_id
      end

      def wait_until_deployed(id)
        print :waiting_for_deploy
        status = poll(id) until %w[Succeeded Failed Stopped].include?(status)
        case status
        when 'Succeeded'
          info :finished_deploy, status
        else
          error :finished_deploy, status
        end
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
            bucket:,
            bundle_type:,
            version: revision_version_info[:version_id],
            e_tag: revision_version_info[:etag],
            key:
          )
        }
      end

      def revision_version_info
        s3.head_object(bucket:, key:)
      rescue Aws::Errors::ServiceError => e
        error e.message
      end

      def github_revision
        {
          revision_type: 'GitHub',
          git_hub_location: {
            commit_id:,
            repository:
          }
        }
      end

      def commit_id
        super || git_sha
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
        super || key =~ /\.(tar|tgz|zip)$/ && ::Regexp.last_match(1) || error(:unknown_bundle_type)
      end

      def description
        interpolate(super || msg(:description), vars:)
      end

      def build_number
        ENV['TRAVIS_BUILD_NUMBER']
      end

      def code_deploy
        @code_deploy ||= Aws::CodeDeploy::Client.new(client_options)
      end

      def s3
        @s3 ||= Aws::S3::Client.new(client_options)
      end

      def client_options
        compact(region:, credentials:, endpoint:)
      end

      def credentials
        Aws::Credentials.new(access_key_id, secret_access_key)
      end
    end
  end
end
