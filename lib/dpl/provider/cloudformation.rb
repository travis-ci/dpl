# frozen_string_literal: true

require 'json'
require 'aws-sdk-cloudformation'
require 'uri'

module DPL
  class Provider
    class CloudFormation < Provider
      def client
        @client ||= ::Aws::CloudFormation::Client.new(cf_options)
      end

      def check_app; end

      def needs_key?
        false
      end

      def access_key_id
        options[:access_key_id] || context.env['AWS_ACCESS_KEY_ID'] || raise(Error, 'missing access_key_id')
      end

      def secret_access_key
        options[:secret_access_key] || context.env['AWS_SECRET_ACCESS_KEY'] || raise(Error, 'missing secret_access_key')
      end

      def filepath
        options[:filepath] || raise(Error, 'Missing file path')
        File.exist?(options[:filepath]) || raise(Error, 'No such file')
        options[:filepath]
      end

      def stack_name_prefix
        options[:stack_name_prefix] || context.env['STACK_NAME_PREFIX'] || ''
      end

      def stack_name
        sn = options[:stack_name] || raise(Error, 'No stack name provided')
        stack_name_prefix + sn
      end

      def cf_options
        defaults = {
          region: options[:region] || context.env['AWS_REGION'] || 'us-east-1',
          credentials: ::Aws::Credentials.new(access_key_id, secret_access_key)
        }

        defaults
      end

      def wait
        options[:wait] || true
      end

      def wait_timeout
        options[:wait_timeout] || 3600
      end

      def promote
        return options[:promote].to_s == 'true' if options[:promote]

        false
      end

      def travis_build_number
        context.env['TRAVIS_BUILD_NUMBER']
      end

      def parameters
        params = options[:parameters] || {}
        output = []
        params.each do |ik, iv|
          (ik, iv) = ik.split('=') if ik.is_a?(String) && ik.include?('=')
          ob = {
            parameter_key: ik,
            parameter_value: iv
          }
          output.push(ob)
        end
        output
      end

      def check_auth
        log "Logging in with Access Key: #{access_key_id[-4..-1].rjust(20, '*')}"
      end

      def push_app
        if stack_exists?
          cf_update
        else
          cf_create
        end
      end

      def cf_update
        if promote
          log 'Updating stack... '

          client.update_stack(
            stack_name: stack_name, # required
            template_body: template_body,
            parameters: parameters
          )
          cf_stream_events_wait(stack_name, :stack_update_complete) if wait

          log 'Update finished.'
        else
          # Create changeset
          log 'Creating update changeset...'
          cf_create_change_set 'UPDATE'
        end
      rescue Aws::CloudFormation::Errors::ValidationError => e
        if e.message.start_with?('No updates are to be performed')
          log 'Stack already up-to-date'
        else
          raise e
        end
      end

      def cf_create
        if promote
          log 'Creating stack...'

          client.create_stack(
            stack_name: stack_name, # required
            template_body: template_body,
            timeout_in_minutes: 1,
            on_failure: 'ROLLBACK', # accepts DO_NOTHING, ROLLBACK, DELETE
            parameters: parameters
          )
          cf_stream_events_wait(stack_name, :stack_create_complete) if wait
        else
          log 'Creating create changeset...'
          cf_create_change_set 'CREATE'
        end
      end

      def cf_create_change_set(type)
        current_timestamp = Time.now.strftime('%Y%m%d%H%M')
        change_set_name = "travis-job-#{travis_build_number}-#{current_timestamp}"
        ccs = client.create_change_set(
          stack_name: stack_name,
          template_body: template_body,
          change_set_name: change_set_name,
          change_set_type: type,
          parameters: parameters,
          description: "Changeset created by Travis job for build number ##{travis_build_number}/commit #{context.env['TRAVIS_COMMIT']}"
        )

        started_at = Time.now
        client.wait_until(:change_set_create_complete,
                          { change_set_name: ccs.id },
                          max_attempts: nil,
                          delay: 5,
                          before_wait: lambda { |_a, _r|
                                         throw :failure if Time.now - started_at > wait_timeout
                                       })
        log 'Changeset created'
      rescue Aws::Waiters::Errors::FailureStateError => e
        cs = client.describe_change_set(change_set_name: ccs.id)
        raise e unless cs.status_reason.start_with?('The submitted information didn\'t contain changes')

        log 'There are no changes in stack. Removing changeset.'
        client.delete_change_set(change_set_name: ccs.id)
      end

      def stack_exists?
        stacks = client.describe_stacks(stack_name: stack_name)
        return true unless stacks.empty?

        false
      end

      def show_events(events)
        events.each do |e|
          puts [
            e.timestamp.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
            e.resource_type,
            e.resource_status,
            e.logical_resource_id,
            e.physical_resource_id,
            e.resource_status_reason
          ].join ' '
        end
      end

      # source: https://github.com/rvedotrc/cfn-events/blob/master/lib/cfn-events/runner.rb
      def events_since_event(from_event)
        se = client.describe_stack_events(stack_name: stack_name)
        return [from_event, []] if se.stack_events.first.event_id == from_event.event_id

        events = []
        se.each_page do |page|
          oldest_new = page.stack_events.index { |event| event.event_id == from_event.event_id }

          if oldest_new
            events.concat page.stack_events[0..oldest_new - 1]
            return [events.first, events.reverse]
          end

          events.concat page.stack_events
        end

        warn 'Last-seen stack event is no longer returned by AWS. Please raise this as a provider\'s bug.'

        [events.first, events.reverse]
      end

      def cf_stream_events_wait(stack_name, _condition)
        @seen_events = Set.new
        latest_event = client.describe_stack_events(stack_name: stack_name).stack_events.first
        stop = false
        stopm = Mutex.new
        event_streamer = Thread.new do
          loop do
            latest_event, display_events = events_since_event(latest_event)
            show_events(display_events)
            break if stopm.synchronize { stop }

            sleep 5
          end
        end

        started_at = Time.now
        client.wait_until(_condition, { stack_name: stack_name },
                          max_attempts: nil,
                          delay: 5,
                          before_wait: lambda { |_a, _r|
                                         throw :failure if Time.now - started_at > wait_timeout
                                       })
      rescue Aws::CloudFormation::Waiters
        stopm.synchronize { stop = true }
        event_streamer.join
      rescue Error => e
        puts "Some error #{e}"
      end

      def template_body
        File.read(filepath)
      end

      def deploy
        super
      rescue ::Aws::CloudFormation::Errors::InvalidAccessKeyId
        raise Error, 'Invalid Access Key Id, Stopping Deploy'
      end
    end
  end
end
