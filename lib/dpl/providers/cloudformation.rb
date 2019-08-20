module Dpl
  module Providers
    class Cloudformation < Provider
      status :dev

      full_name 'AWS CloudFormation'

      description sq(<<-str)
        tbd
      str

      gem 'aws-sdk', '~> 2.0'

      env :aws
      config '~/.aws/credentials', prefix: 'aws'

      opt '--access_key_id ID', 'AWS Access Key ID', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS Secret Key', required: true, secret: true
      opt '--region REGION', 'AWS Region to deploy to', default: 'us-east-1'
      opt '--template STR', 'CloudFormation template file', required: true, note: 'can be either a local path or an S3 URL'
      opt '--stack_name NAME', 'CloudFormation Stack Name.', required: true
      opt '--stack_name_prefix STR', 'CloudFormation Stack Name Prefix.'
      opt '--promote', 'Deploy changes', default: true, note: 'otherwise a change set is created'
      opt '--role_arn ARN', 'AWS Role ARN'
      opt '--sts_assume_role ARN', 'AWS Role ARN for cross account deployments (assumed by travis using given AWS credentials).'
      # TODO change Cl to support array enums:
      # enum: %w(CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND)
      opt '--capabilities STR', 'CloudFormation allowed capabilities', type: :array, see: 'https://docs.aws.amazon.com/AWSCloudFormation/latest/APIReference/API_CreateStack.html'
      opt '--wait', 'Wait for CloutFormation to finish the stack creation and update', default: true
      opt '--wait_timeout SEC', 'How many seconds to wait for stack creation and update.', type: :integer, default: 3600
      opt '--create_timeout SEC', 'How many seconds to wait before the stack status becomes CREATE_FAILED', type: :integer, default: 3600, note: 'valid only when creating a stack'
      # if passing a session_token is not recommended in CI/CD why do we add it to dpl?
      opt '--session_token STR', 'AWS Session Access Token if using STS assume role', note: 'Not recommended on CI/CD'
      opt '--parameters STR', 'Comma-separated list of key/value pairs or ENV var names', eg: 'one=1,TWO'
      opt '--output_file PATH', 'Path to output file to store CloudFormation outputs to'

      msgs login:             'Using Access Key: %{access_key_id}',
           create_stack:      'Creating stack ...',
           promote_stack:     'Promoting stack ...',
           create_change_set: 'Creating change set ...',
           stack_up_to_date:  'Stack already up to date.',
           delete_change_set: 'No changes in stack. Removing changeset.',
           done:              'Done.',
           missing_template:  'File does not exist: %{template}',
           invalid_creds:     'Invalid credentials'

      strs change_set_name:   'travis-ci-build-%{build_number}-%{now}',
           change_set_desc:   'Changeset created by Travis CI job for build #%{build_number} (%{git_sha})'

      def login
        info :login
      end

      def deploy
        stack_exists? ? update : create
        store_events if output_file?
      rescue Aws::CloudFormation::Errors::InvalidAccessKeyId
        error :invalid_creds
      end

      private

        def update
          promote? ? promote : create_change_set(:update)
        rescue Aws::CloudFormation::Errors::ValidationError => e
          raise e unless e.message.start_with?('No updates are to be performed')
          info :stack_up_to_date
        end

        def promote
          info :promote_stack
          client.update_stack(common_params)
          stream_events(stack_name, :stack_update_complete) if wait?
          info :done
        end

        def create
          promote? ? create_stack : create_change_set(:create)
        end

        def create_stack
          info :create_stack
          params = { timeout_in_minutes: create_timeout, on_failure: 'ROLLBACK' }
          client.create_stack(common_params.merge(params))
          stream_events(stack_name, :stack_create_complete) if wait?
          info :done
        end

        def create_change_set(type)
          info :create_change_set
          set = client.create_change_set(common_params.merge(change_set_params(type)))
          wait_for(:change_set_create_complete, change_set_name: set.id) if wait? && !test?
          info :done
        rescue Aws::Waiters::Errors::FailureStateError => e
          raise e unless change_set_contains_changes?(set)
          info :delete_change_set
          client.delete_change_set(change_set_name: set.id)
        end

        def change_set_params(type)
          {
            change_set_type: type.to_s.upcase,
            change_set_name: interpolate(str(:change_set_name)),
            description: interpolate(str(:change_set_desc))
          }
        end

        def change_set_contains_changes?(change_set)
          data = client.describe_change_set(change_set_name: change_set.id)
          data.status_reason.start_with?(%(The submitted information didn't contain changes))
        end

        def stack_exists?
          stack = last_stack
          stack && stack.stack_status != 'REVIEW_IN_PROGRESS'
        rescue Aws::CloudFormation::Errors::ValidationError => e
          raise e unless e.message.include?('does not exist')
          false
        end

        def stream_events(stack_name, condition)
          stream = EventStream.new(client, stack_name, method(:info))
          wait_for(condition, stack_name: stack_name) unless test? # hmm.
        ensure
          stream.stop unless stream.nil?
        end

        def wait_for(cond, params)
          started_at = Time.now
          timeout = lambda { |*| throw :failure if Time.now - started_at > wait_timeout }
          # params = params.merge(max_attempts: nil, delay: 5, before_wait: timeout)
          client.wait_until(cond, params) { |w| w.before_wait(&timeout) }
        end

        def store_events
          logs = last_stack.outputs || {}
          logs = logs.map { |log| "#{log[:output_key]}=#{log[:output_value]}" }
          File.write(output_file, logs.join("\n"))
        end

        def last_stack
          client.describe_stacks(stack_name: stack_name)[:stacks].first
        end

        def common_params
          params = {
            stack_name: stack_name,
            role_arn: role_arn,
            capabilities: capabilities,
            parameters: parameters
          }
          params.merge!(template_param)
          @common_params ||= compact(params)
        end

        def parameters
          @parameters ||= super.to_s.split(',').map do |str|
            key, value = str.split('=', 2)
            { parameter_key: key, parameter_value: value || ENV[key] }
          end
        end

        def create_timeout
          super / 60
        end

        def stack_name
          @stack_name ||= "#{stack_name_prefix}#{super}"
        end

        def capabilities
          # TODO add :separator to Cl for type: :array
          super.map { |str| str.split(',') }.flatten if capabilities?
        end

        def template_param
          str = template
          return { template_url: str } if url?(str)
          return { template_body: read(str) } if file?(str)
          error(:missing_template)
        end

        def client
          @client ||= Aws::CloudFormation::Client.new(client_options)
        end

        def client_options
          params = { region: region }
          params = params.merge(credentials: credentials) if credentials.set?
          params = params.merge(credentials: assume_role(params)) if sts_assume_role?
          params
        end

        def credentials
          Aws::Credentials.new(access_key_id, secret_access_key, session_token)
        end

        def assume_role(params)
          Aws::STS::Client.new(params).assume_role(
            role_arn: sts_assume_role,
            role_session_name: "travis-build-#{build_number}"
          )
        end

        def now
          Time.now.strftime('%Y-%m-%dT%H:%M:%S')
        end

        def url?(str)
          str =~ %r(^https?://)
        end

        class EventStream < Struct.new(:client, :stack_name, :handler)
          attr_reader :thread

          def initialize(*)
            super
            @event = describe_stack_events.stack_events.first
            @thread = Thread.new(&method(:process))
          end

          def stop
            mutex.synchronize { @stop = true }
            thread.join
          end

          private

            def process
              until mutex.synchronize { @stop }
                @event, events = events_since(@event)
                events.each { |e| handler.call(format_event(e)) }
                sleep 5 unless ENV['ENV'] == 'test'
              end
            end

            # source: https://github.com/rvedotrc/cfn-events/blob/master/lib/cfn-events/runner.rb
            def events_since(event)
              described_stack = describe_stack_events
              stack_events = described_stack.stack_events
              return [event, []] if stack_events.first.event_id == event.event_id

              events = []
              described_stack.each_page do |page|


                if (oldest_new = page.stack_events.index { |e| e.event_id == event.event_id })
                  events.concat(page.stack_events[0..oldest_new - 1])
                  return [events.first, events.reverse]
                end
                events.concat(page.stack_events)
              end

              warn %(Last-seen stack event is no longer returned by AWS. Please raise this as a provider's bug.)
              [events.first, events.reverse]
            end

            def describe_stack_events
              client.describe_stack_events(stack_name: stack_name)
            end

            def mutex
              @mutex ||= Mutex.new
            end

            EVENT_KEYS = %i(timestamp resource_type resource_status logical_resource_id
              physical_resource_id resource_status_reason)

            def format_event(event)
              parts = EVENT_KEYS.map { |key| event.send(key) }
              parts[0] = format_timestamp(parts[0])
              parts.join(' ')
            end

            def format_timestamp(timestamp)
              timestamp.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
            end
        end
    end
  end
end
