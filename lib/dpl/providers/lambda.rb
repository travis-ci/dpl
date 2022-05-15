require 'dpl/helper/zip'

module Dpl
  module Providers
    class Lambda < Provider
      register :lambda

      status :stable

      full_name 'AWS Lambda'

      description sq(<<-str)
        tbd
      str

      gem 'aws-sdk-lambda', '~> 1.0'
      gem 'rubyzip', '~> 1.2.2', require: 'zip'

      env :aws, :lambda
      config '~/.aws/credentials', '~/.aws/config', prefix: 'aws'

      opt '--access_key_id ID',       'AWS access key id', required: true, secret: true
      opt '--secret_access_key KEY',  'AWS secret key', required: true, secret: true
      opt '--region REGION',          'AWS region the Lambda function is running in', default: 'us-east-1'
      opt '--function_name FUNC',     'Name of the Lambda being created or updated', required: true
      opt '--role ROLE',              'ARN of the IAM role to assign to the Lambda function', note: 'required when creating a new function'
      opt '--handler_name NAME',      'Function the Lambda calls to begin execution.', note: 'required when creating a new function'
      opt '--module_name NAME',       'Name of the module that exports the handler', default: 'index', requires: :handler_name
      opt '--description DESCR',      'Description of the Lambda being created or updated', interpolate: true
      opt '--timeout SECS',           'Function execution time (in seconds) at which Lambda should terminate the function', default: 3
      opt '--memory_size MB',         'Amount of memory in MB to allocate to this Lambda', default: 128
      opt '--subnet_ids IDS',         'List of subnet IDs to be added to the function', type: :array, note: 'Needs the ec2:DescribeSubnets and ec2:DescribeVpcs permission for the user of the access/secret key to work'
      opt '--security_group_ids IDS', 'List of security group IDs to be added to the function', type: :array, note: 'Needs the ec2:DescribeSecurityGroups and ec2:DescribeVpcs permission for the user of the access/secret key to work'
      opt '--environment VARS',       'List of Environment Variables to add to the function', type: :array, format: /[\w\-]+=.+/, note: 'Can be encrypted for added security', alias: :environment_variables
      opt '--runtime NAME',           'Lambda runtime to use', note: 'required when creating a new function', default: 'nodejs10.x', enum: %w(nodejs14.x nodejs12.x nodejs10.x python3.8 python3.7 python3.6 python2.7 ruby2.7 ruby2.5 java11 java8.al2 java8 go1.x dotnetcore3.1 dotnetcore2.1 provided.al2 provided)
      opt '--dead_letter_arn ARN',    'ARN to an SNS or SQS resource used for the dead letter queue.'
      opt '--kms_key_arn ARN',        'KMS key ARN to use to encrypt environment_variables.'
      opt '--tracing_mode MODE',      'Tracing mode', default: 'PassThrough', enum: %w(Active PassThrough), note: 'Needs xray:PutTraceSegments xray:PutTelemetryRecords on the role'
      opt '--layers LAYERS',          'Function layer arns', type: :array
      opt '--function_tags TAGS',     'List of tags to add to the function', type: :array, format: /[\w\-]+=.+/, note: 'Can be encrypted for added security'
      opt '--publish',                'Create a new version of the code instead of replacing the existing one.'
      opt '--zip PATH',               'Path to a packaged Lambda, a directory to package, or a single file to package', default: '.'
      opt '--dot_match',              'Include hidden .* files to the zipped archive'

      msgs login:           'Using Access Key: %{access_key_id}',
           create_function: 'Creating function %{function_name}.',
           update_config:   'Updating existing function %{function_name}.',
           update_tags:     'Updating tags.',
           update_code:     'Updating code.',
           description:     'Deploy build %{build_number} to AWS Lambda via Travis CI'

      def login
        info :login
      end

      def deploy
        exists? ? update : create
      rescue Aws::Errors::ServiceError => e
        error e.message
      end

      private

        def exists?
          !!client.get_function(function_name: function_name)
        rescue ::Aws::Lambda::Errors::ResourceNotFoundException
          false
        end

        def create
          info :create_function
          config = function_config
          config = config.merge(code: { zip_file: function_zip })
          config = config.merge(tags: function_tags) if function_tags?
          client.create_function(config)
        end

        def update
          arn = update_config
          update_tags(arn) if function_tags?
          update_code
        end

        def update_config
          info :update_config
          response = client.update_function_configuration(function_config)
          response.function_arn
        end

        def update_tags(arn)
          info :update_tags
          client.tag_resource(tag_resource(arn))
        end

        def update_code
          info :update_code
          client.update_function_code(function_code)
        end

        def function_config
          compact(
            function_name: function_name,
            role: role,
            handler: handler,
            description: description,
            timeout: timeout,
            memory_size: memory_size,
            vpc_config: vpc_config,
            environment: environment,
            runtime: runtime,
            dead_letter_config: dead_letter_arn,
            kms_key_arn: kms_key_arn,
            tracing_config: tracing_config,
            layers: layers
          )
        end

        def tag_resource(arn)
          {
            resource: arn,
            tags: function_tags
          }
        end

        def function_code
          {
            function_name: function_name,
            zip_file: function_zip,
            publish: publish?
          }
        end

        def handler
          Handler.new(runtime, module_name, handler_name).to_s if handler_name?
        end

        def function_zip
          Zip.new(zip, tmp_filename, opts).zip
        end

        def vpc_config
          compact(subnet_ids: subnet_ids, security_group_ids: security_group_ids)
        end

        def environment
          { variables: split_vars(super) } if environment?
        end

        def dead_letter_arn
          { target_arn: super } if dead_letter_arn?
        end

        def tracing_config
          { mode: tracing_mode } if tracing_mode?
        end

        def function_tags
          split_vars(super) if function_tags?
        end

        def description
          interpolate(super || msg(:description), vars: vars)
        end

        def client
          @client ||= Aws::Lambda::Client.new(region: region, credentials: credentials)
        end

        def credentials
          Aws::Credentials.new(access_key_id, secret_access_key)
        end

        def split_vars(vars)
          vars.map { |var| var.split('=', 2) }.to_h
        end

        def tmp_filename
          @tmp_filename ||= "#{tmp_dir}/#{repo_name}.zip"
        end

        class Handler < Struct.new(:runtime, :module_name, :handler_name)
          SEP = {
            default: '.',
            java:    '::',
            dotnet:  '::',
            go:      ''
          }

          def to_s
            [go? ? nil : module_name, sep, handler_name].compact.join
          end

          def sep
            key = SEP.keys.detect { |key| runtime.start_with?(key.to_s) }
            SEP[key || :default]
          end

          def go?
            runtime.start_with?('go')
          end
        end
    end
  end
end
