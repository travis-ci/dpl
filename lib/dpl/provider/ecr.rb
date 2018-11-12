require 'aws-sdk'
require 'docker-api'
require 'net/http'

module DPL
  class Provider
    class Ecr < Provider
      def needs_key?
        false
      end

      def validate
        issues = []
        issues << 'source or target option missing' unless ([:source, :target] - options.keys).empty?
        issues << 'aws_region option or env AWS_REGION missing' if aws_regions.empty?
        issues << 'aws_access_key_id option or env AWS_ACCESS_KEY_ID missing' unless options[:aws_access_key_id] || ENV['AWS_ACCESS_KEY_ID']
        raise DPL::Error, "dpl-ecr failed validation: #{issues.join(', ')}" unless issues.empty?
      end

      def check_auth
        validate
        aws_regions.each do |aws_region|
          auth_region(aws_region)
        end
      end

      def check_app
        image
      rescue Docker::Error::NotFoundError
        raise DPL::Error, "No such image #{options[:source]} in local Docker repo"
      end

      def push_app
        aws_regions.product([*options[:target]]).each do |aws_region, repo_tag|
          push_image(aws_region, repo_tag)
        end
      end

      def endpoints
        @endpoints ||= {}
      end

      private

      def aws_credentials
        options.select {|k, v| [:aws_access_key_id, :aws_secret_access_key].include?(k) }
      end

      def registry_ids
        if (aws_account_id = options.fetch(:aws_account_id, ENV['AWS_ACCOUNT_ID']))
          {registry_ids: [aws_account_id]}
        else
          {}
        end
      end

      def aws_regions
        [*options.fetch(:aws_region, ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION'])]
      end

      def auth_region(aws_region)
        ecr_client = Aws::ECR::Client.new(region: aws_region, **aws_credentials)
        auth_response = ecr_client.get_authorization_token(**registry_ids)
        registry_auth = auth_response.authorization_data[0]
        username, password = Base64.decode64(registry_auth.authorization_token).split(':')
        Docker.authenticate!(
          username: username,
          password: password,
          serveraddress: registry_auth.proxy_endpoint,
        )
        endpoints[aws_region] = registry_auth.proxy_endpoint
      end

      def image
        @image ||= Docker::Image.get(options[:source])
      end

      def push_image(aws_region, repo_tag)
        endpoint = endpoints[aws_region].sub(/^https?:\/\//, '')
        repo_tag = "#{endpoint}/#{repo_tag}"
        image.push(nil, repo_tag: repo_tag)
      end
    end
  end
end
