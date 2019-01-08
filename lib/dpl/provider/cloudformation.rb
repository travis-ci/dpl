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

      def parameters
        params = options[:parameters] || {}
        output = []
        params.each do |ik, iv|
          (ik,iv) = ik.split('=') if ik.is_a?(String) && ik.include?('=')
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
        begin
          log 'Trying to update stack... '
          w = client.update_stack(
            stack_name: stack_name, # required
            template_body: template_body,
            parameters: parameters
          )
          puts "#{w}"
          client.wait_until(:stack_update_complete, {}, {
            stack_name: w,
            before_wait: -> (a, r) do
              puts "waiting: #{a}; #{r}"
            end
          })
          # client.wait_until(:stack_update_complete, {}, {
          #   before_wait: -> (a, r) do
          #     r.stack_status.match(/_(FAILED|COMPLETE)$/)
          #   end
          # })
        rescue Aws::CloudFormation::Errors::ValidationError => e
          case
            when e.message.start_with?('No updates are to be performed')
              log 'Stack already up-to-date'
              w = nil
            when e.message.end_with?('does not exist')
              log 'Stack does not exist. Creating stack...'
              w = client.create_stack(
                stack_name: stack_name, # required
                template_body: template_body,
                timeout_in_minutes: 1,
                on_failure: 'ROLLBACK', # accepts DO_NOTHING, ROLLBACK, DELETE
                parameters: parameters
              )
            else
              raise e
          end

        end
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
