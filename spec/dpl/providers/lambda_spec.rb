# frozen_string_literal: true

describe Dpl::Providers::Lambda do
  include Support::Matchers::Aws

  let(:args)   { |e| required + args_from_description(e) }
  let(:client) { Aws::Lambda::Client.new(stub_responses: responses) }

  let(:responses) do
    {
      get_function: lambda { |c|
        exists ? {} : raise(Aws::Lambda::Errors::ResourceNotFoundException.new(c, 'error'))
      },
      create_function: {},
      update_function_configuration: { function_arn: 'arn' },
      update_function_code: {},
      tag_resource: {}
    }
  end

  before do
    allow(Aws::Lambda::Client).to receive(:new).and_return(client)
    allow_any_instance_of(Aws::Lambda::Client).to receive(:wait_until).and_return({})
  end

  before { |c| subject.run if run?(c) }

  file 'one'

  # opt '--dot_match',                  'Include hidden .* files to the zipped archive'

  describe 'function does not exist' do
    let(:required) { %w[--access_key_id id --secret_access_key key --function_name func --role role --handler_name handler] }
    let(:exists) { false }

    describe 'by default', record: true do
      it { is_expected.to have_run '[info] Using Access Key: i*******************' }
      it { is_expected.to have_run '[info] Creating function func.' }
      it { is_expected.to have_run_in_order }

      it { is_expected.to create_function FunctionName: 'func' }
      it { is_expected.to create_function Runtime: 'nodejs12.x' }
      it { is_expected.to create_function Code: { ZipFile: instance_of(String) } }
      it { is_expected.to create_function Description: 'Deploy build 1 to AWS Lambda via Travis CI' }
      it { is_expected.to create_function Handler: 'index.handler' }
      it { is_expected.to create_function Role: 'role' }
      it { is_expected.to create_function Timeout: 3 }
      it { is_expected.to create_function MemorySize: 128 }
      it { is_expected.to create_function TracingConfig: { Mode: 'PassThrough' } }
    end

    describe 'given --module_name other --handler_name handler' do
      it { is_expected.to create_function Handler: 'other.handler' }
    end

    describe 'given --description other' do
      it { is_expected.to create_function Description: 'other' }
    end

    describe 'given --timeout 1' do
      it { is_expected.to create_function Timeout: 1 }
    end

    describe 'given --memory_size 64' do
      it { is_expected.to create_function MemorySize: 64 }
    end

    describe 'given --runtime python2.7' do
      it { is_expected.to create_function Runtime: 'python2.7' }
    end

    describe 'given --runtime java8' do
      it { is_expected.to create_function Handler: 'index::handler' }
    end

    describe 'given --runtime dotnetcore2.1' do
      it { is_expected.to create_function Handler: 'index::handler' }
    end

    describe 'given --runtime go1.x' do
      it { is_expected.to create_function Handler: 'handler' }
    end

    describe 'given --subnet_ids one --subnet_ids two' do
      it { is_expected.to create_function VpcConfig: { SubnetIds: %w[one two] } }
    end

    describe 'given --security_group_ids one --security_group_ids two' do
      it { is_expected.to create_function VpcConfig: { SecurityGroupIds: %w[one two] } }
    end

    describe 'given --dead_letter_arn arn' do
      it { is_expected.to create_function DeadLetterConfig: { TargetArn: 'arn' } }
    end

    describe 'given --tracing_mode Active' do
      it { is_expected.to create_function TracingConfig: { Mode: 'Active' } }
    end

    describe 'given --environment_variables ONE=one --environment_variables TWO=two' do
      it { is_expected.to create_function Environment: { Variables: { ONE: 'one', TWO: 'two' } } }
    end

    describe 'given --kms_key_arn arn' do
      it { is_expected.to create_function KMSKeyArn: 'arn' }
    end

    describe 'given --function_tags key=value' do
      it { is_expected.to create_function Tags: { key: 'value' } }
    end
  end

  describe 'function exists' do
    let(:required) { %w[--access_key_id id --secret_access_key key --function_name func] }
    let(:exists) { true }

    describe 'by default' do
      it { is_expected.to have_run '[info] Using Access Key: i*******************' }
      it { is_expected.to have_run '[info] Updating existing function func.' }
      it { is_expected.to have_run '[info] Updating code.' }

      it { is_expected.to update_function_config Runtime: 'nodejs12.x' }
      it { is_expected.to update_function_config Description: 'Deploy build 1 to AWS Lambda via Travis CI' }
      it { is_expected.to update_function_config Timeout: 3 }
      it { is_expected.to update_function_config MemorySize: 128 }
      it { is_expected.to update_function_config TracingConfig: { Mode: 'PassThrough' } }
      it { is_expected.to update_function_code ZipFile: instance_of(String), Publish: false }
    end

    describe 'given --role role' do
      it { is_expected.to update_function_config Role: 'role' }
    end

    describe 'given --handler_name handler' do
      it { is_expected.to update_function_config Handler: 'index.handler' }
    end

    describe 'given --module_name other --handler_name handler' do
      it { is_expected.to update_function_config Handler: 'other.handler' }
    end

    describe 'given --description other' do
      it { is_expected.to update_function_config Description: 'other' }
    end

    describe 'given --timeout 1' do
      it { is_expected.to update_function_config Timeout: 1 }
    end

    describe 'given --memory_size 64' do
      it { is_expected.to update_function_config MemorySize: 64 }
    end

    describe 'given --runtime python2.7' do
      it { is_expected.to update_function_config Runtime: 'python2.7' }
    end

    describe 'given --subnet_ids one --subnet_ids two' do
      it { is_expected.to update_function_config VpcConfig: { SubnetIds: %w[one two] } }
    end

    describe 'given --security_group_ids one --security_group_ids two' do
      it { is_expected.to update_function_config VpcConfig: { SecurityGroupIds: %w[one two] } }
    end

    describe 'given --dead_letter_arn arn' do
      it { is_expected.to update_function_config DeadLetterConfig: { TargetArn: 'arn' } }
    end

    describe 'given --tracing_mode Active' do
      it { is_expected.to update_function_config TracingConfig: { Mode: 'Active' } }
    end

    describe 'given --environment_variables ONE=one --environment_variables TWO=two' do
      it { is_expected.to update_function_config Environment: { Variables: { ONE: 'one', TWO: 'two' } } }
    end

    describe 'given --kms_key_arn arn' do
      it { is_expected.to update_function_config KMSKeyArn: 'arn' }
    end

    describe 'given --publish' do
      it { is_expected.to update_function_code Publish: true }
    end

    describe 'given --function_tags key=value' do
      it { is_expected.to tag_resource Tags: { key: 'value' } }
    end

    describe 'given --layers one --layers two' do
      it { is_expected.to update_function_config Layers: %w[one two] }
    end
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { |_e| %w[--function_name func --role role --handler_name handler] }
    let(:exists) { false }

    file '~/.aws/credentials', <<-STR.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    STR

    before { subject.run }

    it { is_expected.to have_run '[info] Using Access Key: ac******************' }
  end

  describe 'with ~/.aws/config', run: false do
    let(:args) { |_e| %w[--access_key_id id --secret_access_key secret] }
    let(:exists) { false }

    file '~/.aws/config', <<-STR.sub(/^\s*/, '')
      [default]
      function_name=func
      handler_name=handler
      role=role
    STR

    before { subject.run }

    it { is_expected.to create_function FunctionName: 'func' }
    it { is_expected.to create_function Role: 'role' }
    it { is_expected.to create_function Handler: 'index.handler' }
  end
end
