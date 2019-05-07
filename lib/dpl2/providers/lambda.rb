module Dpl
  module Providers
    class Lambda < Provider
      summary 'Lambda deployment provider'

      description <<~str
        tbd
      str

      opt '--access_key_id',         'AWS Access Key ID'
      opt '--secret_access_key',     'AWS Secret Key'
      opt '--region',                'AWS Region the Lambda function is running in', default: 'us-east-1'
      opt '--function_name',         'Name of the Lambda being created or updated', required: true
      opt '--role',                  'ARN of the IAM role to assign to the Lambda function', required: true
      opt '--handler_name',          'Function the Lambda calls to begin executio.', required: true
      opt '--dot_match',             'Include hidden .* files to the zipped archive'
      opt '--module_name',           'Name of the module that exports the handler', default: 'index'
      opt '--zip',                   'Path to a packaged Lambda, a directory to package, or a single file to package', default: '.'
      opt '--description',           'Description of the Lambda being created or updated'
      opt '--timeout',               'Function execution time (in seconds) at which Lambda should terminate the function', default: 3
      opt '--memory_size',           'Amount of memory in MB to allocate to this Lambda. Defaults to 128.', default: 128
      opt '--runtime',               'Lambda runtime to use', default: 'node'
      opt '--publish',               'Do not replace the code of the Lambda function, but create a new version of it'
      opt '--subnet_ids',            'List of subnet IDs to be added to the function. Needs the ec2:DescribeSubnets and ec2:DescribeVpcs permission for the user of the access/secret key to work.'
      opt '--security_group_ids',    'List of security group IDs to be added to the function. Needs the ec2:DescribeSecurityGroups and ec2:DescribeVpcs permission for the user of the access/secret key to work.'
      opt '--dead_letter_arn',       'ARN to an SNS or SQS resource used for the dead letter queue.'
      opt '--tracing_mode',          '"Active" or "PassThrough" only. Default is "PassThrough". Needs the xray:PutTraceSegments and xray:PutTelemetryRecords on the role for this to work.'
      opt '--environment_variables', 'List of Environment Variables to add to the function, needs to be in the format of KEY=VALUE. Can be encrypted for added security.'
      opt '--kms_key_arn',           'KMS key ARN to use to encrypt environment_variables.'
      opt '--function_tags',         'List of tags to add to the function, needs to be in the format of KEY=VALUE. Can be encrypted for added security.'
    end
  end
end
