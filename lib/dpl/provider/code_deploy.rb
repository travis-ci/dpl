require 'json'
require 'aws-sdk'

module DPL
  class Provider
    class CodeDeploy < Provider
      def code_deploy
        @code_deploy ||= Aws::CodeDeploy::Client.new(code_deploy_options)
      end

      def s3api
        @s3api ||= Aws::S3::Client.new(code_deploy_options)
      end

      def code_deploy_options
        code_deploy_options = {
          region:      options[:region] || 'us-east-1',
          credentials: Aws::Credentials.new(access_key_id, secret_access_key)
        }
        code_deploy_options[:endpoint] = options[:endpoint] if options[:endpoint]
        code_deploy_options
      end

      def access_key_id
        options[:access_key_id] || context.env['AWS_ACCESS_KEY_ID'] || raise(Error, "missing access_key_id")
      end

      def secret_access_key
        options[:secret_access_key] || context.env['AWS_SECRET_ACCESS_KEY'] || raise(Error, "missing secret_access_key")
      end

      def needs_key?
        false
      end

      def revision
        case options[:revision_type].to_s.downcase
        when "s3"     then s3_revision
        when "github" then github_revision
        when ""       then options[:bucket] ? s3_revision : github_revision
        else error("unknown revision type %p" % options[:revision_type])
        end
      end

      def revision_version_info
        s3api.head_object({
          bucket: option(:bucket),
          key: s3_key
        })
      rescue Aws::Errors::ServiceError
        {}
      end

      def s3_revision
        info = {
          revision_type: 'S3',
          s3_location: {
            bucket:      option(:bucket),
            bundle_type: bundle_type,
            key:         s3_key,
          }
        }
        unless revision_version_info.empty?
          info[:s3_location][:version] = revision_version_info[:version_id]
          info[:s3_location][:e_tag]   = revision_version_info[:etag]
        end

        info
      end

      def github_revision
        {
          revision_type: 'GitHub',
          git_hub_location: {
            commit_id:  options[:commit_id]  || context.env['TRAVIS_COMMIT']    || `git rev-parse HEAD`.strip,
            repository: options[:repository] || context.env['TRAVIS_REPO_SLUG'] || option(:repository)
          }
        }
      end

      def push_app
        rev = revision()
        rev_info = rev[:s3_location]

        if rev_info && rev_info[:version]
          log "Registering app revision with version=#{rev_info[:version]}, etag=#{rev_info[:e_tag]}"
          code_deploy.register_application_revision({
            revision:               rev,
            application_name:       options[:application] || option(:application_name),
            description:            options[:description] || default_description
          })
        end

        data = code_deploy.create_deployment({
          revision:               revision,
          application_name:       options[:application]      || option(:application_name),
          deployment_group_name:  options[:deployment_group] || option(:deployment_group_name),
          description:            options[:description]      || default_description
        })
        log "Triggered deployment #{data.deployment_id.inspect}."
        return unless options[:wait_until_deployed]
        print "Deploying "
        deployment = wait_until_deployed(data[:deployment_id])
        print "\n"
        if deployment[:status] == 'Succeeded'
          log "Deployment successful."
        else
          error "Deployment failed."
        end
      rescue Aws::CodeDeploy::Errors::DeploymentLimitExceededException => exception
        error(exception.message)
      end

      def wait_until_deployed(deployment_id)
        deployment = {}
        loop do
          result = code_deploy.get_deployment(deployment_id: deployment_id)
          deployment = result[:deployment_info]
          break if deployment[:status] == "Succeeded" || deployment[:status] == "Failed" || deployment[:status] == "Stopped"
          print "."
          sleep 5
        end
        deployment
      end

      def bundle_type
        if s3_key =~ /\.(tar|tgz|zip)$/
          options[:bundle_type] || $1
        else
          option(:bundle_type)
        end
      end

      def s3_key
        options[:key] || option(:s3_key)
      end

      def default_description
        "Deploy build #{context.env['TRAVIS_BUILD_NUMBER']} via Travis CI"
      end

      def check_auth
        log "Logging in with Access Key: #{access_key_id[-4..-1].rjust(20, '*')}"
      end

      def cleanup
      end

      def uncleanup
      end
    end
  end
end
