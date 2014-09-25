require 'json'

module DPL
  class Provider
    class SDS < Provider
      requires 'aws-sdk-core', pre: true

      def sds
        @sds ||= begin
          Aws.add_service('SDS', api: File.expand_path("../SDS.api.json", __FILE__)) unless defined? Aws::SDS
          Aws::SDS::Client.new(sds_options)
        end
      end

      def sds_options
        sds_options = {
          region:      options[:region] || 'us-east-1',
          credentials: Aws::Credentials.new(option(:access_key_id), option(:secret_access_key))
        }
        sds_options[:endpoint] = options[:endpoint] if options[:endpoint]
        sds_options
      end

      def needs_key?
        false
      end

      def push_app
        sds.create_deployment({
          s3_location: { bucket: option(:bucket), bundle_type: bundle_type, key: s3_key },
          application_name:       options[:application]      || option(:application_name),
          deployment_group_name:  options[:deployment_group] || option(:deployment_group_name),
          reason:                 options[:reason]           || default_reason
        })
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

      def default_reason
        "Deploy build #{ENV['TRAVIS_BUILD_NUMBER']} via Travis CI"
      end

      def check_auth
        log "Logging in with Access Key: #{option(:access_key_id)[-4..-1].rjust(20, '*')}"
      end

      def cleanup
      end

      def uncleanup
      end
    end
  end
end
