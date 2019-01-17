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
          region: options[:region] || 'us-east-1',
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
        log 'Trying to update stack... '

        w = client.update_stack(
          stack_name: stack_name, # required
          template_body: template_body,
          parameters: parameters
        )
        cf_stream_events_wait(stack_name, :stack_update_complete) if wait

        log 'Update finished.'
      rescue Aws::CloudFormation::Errors::ValidationError => e
        if e.message.start_with?('No updates are to be performed')
          log 'Stack already up-to-date'
          w = nil
        elsif e.message.end_with?('does not exist')
          log 'Stack does not exist. Creating stack...'
          w = client.create_stack(
            stack_name: stack_name, # required
            template_body: template_body,
            timeout_in_minutes: 1,
            on_failure: 'ROLLBACK', # accepts DO_NOTHING, ROLLBACK, DELETE
            parameters: parameters
          )
          cf_stream_events_wait(stack_name, :stack_create_complete) if wait
        else
          raise e
        end
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
        client.wait_until(_condition, { stack_name: stack_name }, {
          max_attempts: nil,
          delay: 5,
          before_wait: ->(a,r){
            throw :failure if Time.now - started_at > wait_timeout
          }
        })
      rescue Aws::CloudFormation::Waiter
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
