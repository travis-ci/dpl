require 'dpl/helper/zip'

module Dpl
  module Providers
    class Lambda < Provider
      gem 'aws-sdk', '~> 2.0'
      gem 'rubyzip', '~> 1.2.2', require: 'zip'

      full_name 'AWS Lambda'

      description sq(<<-str)
        tbd
      str

      env :aws

      opt '--access_key_id ID',           'AWS access key id', required: true, secret: true
      opt '--secret_access_key KEY',      'AWS secret key', required: true, secret: true
      opt '--region REGION',              'AWS region the Lambda function is running in', default: 'us-east-1'
      opt '--function_name FUNC',         'Name of the Lambda being created or updated', required: true
      opt '--role ROLE',                  'ARN of the IAM role to assign to the Lambda function', required: true
      opt '--handler_name NAME',          'Function the Lambda calls to begin executio.', required: true
      opt '--dot_match',                  'Include hidden .* files to the zipped archive'
      opt '--module_name NAME',           'Name of the module that exports the handler', default: 'index'
      opt '--zip PATH',                   'Path to a packaged Lambda, a directory to package, or a single file to package', default: '.'
      opt '--description DESCR',          'Description of the Lambda being created or updated'
      opt '--timeout SECS',               'Function execution time (in seconds) at which Lambda should terminate the function', default: 3
      opt '--memory_size MB',             'Amount of memory in MB to allocate to this Lambda', default: 128
      opt '--runtime NAME',               'Lambda runtime to use', default: 'nodejs8.10', enum: %w(java8 nodejs8.10 nodejs10.x python2.7 python3.6 python3.7 dotnetcore2.1 go1.x ruby2.5)
      opt '--publish',                    'Create a new version of the code instead of replacing the existing one.'
      opt '--subnet_ids IDS',             'List of subnet IDs to be added to the function', type: :array, note: 'Needs the ec2:DescribeSubnets and ec2:DescribeVpcs permission for the user of the access/secret key to work'
      opt '--security_group_ids IDS',     'List of security group IDs to be added to the function', type: :array, note: 'Needs the ec2:DescribeSecurityGroups and ec2:DescribeVpcs permission for the user of the access/secret key to work'
      opt '--dead_letter_arn ARN',        'ARN to an SNS or SQS resource used for the dead letter queue.'
      opt '--tracing_mode MODE',          'Tracing mode', default: 'PassThrough', enum: %w(Active PassThrough), note: 'Needs xray:PutTraceSegments xray:PutTelemetryRecords on the role'
      opt '--environment_variables VARS', 'List of Environment Variables to add to the function', type: :array, format: /[\w\-]+=.+/, note: 'Can be encrypted for added security'
      opt '--kms_key_arn ARN',            'KMS key ARN to use to encrypt environment_variables.'
      opt '--function_tags TAGS',         'List of tags to add to the function', type: :array, format: /[\w\-]+=.+/, note: 'Can be encrypted for added security'

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
            description: description,
            timeout: timeout,
            memory_size: memory_size,
            role: role,
            handler: handler,
            runtime: runtime,
            vpc_config: vpc_config,
            environment: environment_variables,
            dead_letter_config: dead_letter_arn,
            kms_key_arn: kms_key_arn,
            tracing_config: tracing_mode
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
          "#{module_name}.#{handler_name}"
        end

        def function_zip
          Zip.new(zip, tmp_filename, opts).zip
        end

        def vpc_config
          compact(subnet_ids: subnet_ids, security_group_ids: security_group_ids)
        end

        def environment_variables
          { variables: split_vars(super) } if environment_variables?
        end

        def dead_letter_arn
          { target_arn: super } if dead_letter_arn?
        end

        def tracing_mode
          { mode: super } if tracing_mode?
        end

        def function_tags
          split_vars(super) if function_tags?
        end

        def description
          super || interpolate(msg(:description))
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
    end
  end
end
