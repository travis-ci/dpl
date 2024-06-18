# frozen_string_literal: true

module Dpl
  module Providers
    class Ecr < Provider
      status :alpha

      full_name 'AWS ECR'

      description sq(<<-STR)
        tbd
      STR

      gem 'nokogiri', '~> 1.15'
      gem 'aws-sdk-ecr', '~> 1.0'
      # gem 'docker-api', '~> 1.34'
      gem 'json'

      env :aws

      opt '--access_key_id ID', 'AWS access key', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret access key', required: true, secret: true
      opt '--account_id ID', 'AWS Account ID', note: 'Required if the repository is owned by a different account than the IAM user'
      opt '--source SOURCE', 'Image to push', note: 'can be the id or the name and optional tag (e.g. mysql:5.6)', required: true
      opt '--target TARGET', 'Comma separated list of partial repository names to push to', eg: 'image-one:tag,image-two', required: true
      opt '--region REGION', 'Comma separated list of regions to push to', default: 'us-east-1'

      msgs login: 'Using Access Key: %{access_key_id}',
           auth_region: 'Authenticated with %{url}',
           deploy: 'Pushing image %{source} to regions %{regions} as %{targets}',
           image_pushed: 'Pushed image %{source} to region %{region} as %{target}'

      cmds login: 'docker login -u %{user} -p %{pass} %{url}',
           tag: 'docker tag %{source} %{url}/%{repo}:%{tag}',
           push: 'docker push %{url}/%{repo}'

      errs unknown_image: 'Image %{source} not found in the local Docker repository'

      attr_reader :endpoints

      def login
        info :login
        auth_regions
      end

      def validate
        # TODO: validate the image exists locally
      end

      def deploy
        info :deploy, regions: regions.join(', '), targets: targets.join(', ')
        regions.product(targets).each do |region, target|
          push(region, target)
        end
      end

      private

      def push(region, target)
        url, repo, tag = endpoints[region], *target.split(':')
        shell :tag, url:, repo:, tag: tag || 'latest'
        shell(:push, url:, repo:)
        info :image_pushed, region:, target:
      end

      def auth_regions
        @endpoints = regions.map { |region| [region, auth_region(region)] }.to_h
      end

      def auth_region(region)
        token = auth_token(region)
        user, pass = parse_auth(token.authorization_token)
        url = token.proxy_endpoint
        shell :login, user:, pass:, url:, echo: false, silent: true
        info(:auth_region, url:)
        strip_protocol(url)
      end

      def auth_token(region)
        ecr(region).get_authorization_token(registry_ids).authorization_data[0]
      end

      def registry_ids
        account_id? ? { registry_ids: [account_id] } : {}
      end

      def regions
        # not sure how this was meant to be normalized when being a YAML list
        region.split(',')
      end

      def targets
        # not sure how this was meant to be normalized when being a YAML list
        target.split(',')
      end

      def creds
        @creds ||= only(opts, :access_key_id, :secret_access_key)
      end

      def ecr(region)
        Aws::ECR::Client.new(region:, **creds)
      end

      def parse_auth(str)
        user, pass = Base64.decode64(str).split(':')
        [user, pass.chomp]
      end

      def strip_protocol(url)
        url.sub(%r{^https?://}, '')
      end

      def progress(events)
        events.split("\r\n").each do |event|
          event = JSON.parse(event)
          if e = event['error']
            error e
          elsif %w[Preparing Pushing].include?(event['status'])
            nil
          elsif event['id']
            info "#{event['status']} [#{event['id']}]"
          elsif event['status']
            info event['status']
          end
        end
      end
    end
  end
end
