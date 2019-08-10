describe Dpl::Providers::Lambda do
  let(:args) { |e| required + args_from_description(e) }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }
  let(:exists) { false }

  matcher :have_called do |key, params = {}|
    match do |*|
      @body = symbolize(JSON.parse(requests[key][0].body.read)) if requests[key].any?
      @body ? expect(@body).to(include params) : false
    end

    failure_message do
      "Expected it to have called #{key.inspect}\n\n  #{params.inspect}\n\nbut it was not. Instead it was called with:\n\n  #{@body}"
    end
  end

  before do
    Aws.config[:lambda] = {
      stub_responses: {
        get_function: ->(ctx) {
          requests[:get_function] << ctx.http_request
          exists ? {} : raise(Aws::Lambda::Errors::ResourceNotFoundException.new(ctx, 'error'))
        },
        create_function: ->(ctx) {
          requests[:create_function] << ctx.http_request
        },
        update_function_configuration: ->(ctx) {
          requests[:update_function_config] << ctx.http_request
          { function_arn: 'arn' }
        },
        update_function_code: ->(ctx) {
          requests[:update_function_code] << ctx.http_request
        },
        tag_resource: ->(ctx) {
          requests[:tag_resource] << ctx.http_request
        }
      }
    }
  end

  after { Aws.config.clear }

  file 'one'

  # opt '--dot_match',                  'Include hidden .* files to the zipped archive'

  describe 'function does not exist' do
    let(:required) { %w(--access_key_id id --secret_access_key key --function_name func --role role --handler handler) }
    let(:exists) { false }

    before { subject.run }

    describe 'by default', record: true do
      it { should have_run '[info] Using Access Key: i*******************' }
      it { should have_run '[info] Creating function func.' }
      it { should have_run_in_order }

      it { should have_called :create_function, FunctionName: 'func' }
      it { should have_called :create_function, Runtime: 'nodejs8.10' }
      it { should have_called :create_function, Code: { ZipFile: instance_of(String) } }
      it { should have_called :create_function, Description: 'Deploy build 1 to AWS Lambda via Travis CI' }
      it { should have_called :create_function, Handler: 'index.handler' }
      it { should have_called :create_function, Role: 'role' }
      it { should have_called :create_function, Timeout: 3 }
      it { should have_called :create_function, MemorySize: 128 }
      it { should have_called :create_function, TracingConfig: { Mode: 'PassThrough' } }
    end

    describe 'given --module_name other --handler handler' do
      it { should have_called :create_function, Handler: 'other.handler' }
    end

    describe 'given --description other' do
      it { should have_called :create_function, Description: 'other' }
    end

    describe 'given --timeout 1' do
      it { should have_called :create_function, Timeout: 1 }
    end

    describe 'given --memory_size 64' do
      it { should have_called :create_function, MemorySize: 64 }
    end

    describe 'given --runtime python2.7' do
      it { should have_called :create_function, Runtime: 'python2.7' }
    end

    describe 'given --runtime java8' do
      it { should have_called :create_function, Handler: 'index::handler' }
    end

    describe 'given --subnet_ids one --subnet_ids two' do
      it { should have_called :create_function, VpcConfig: { SubnetIds: ['one', 'two'] } }
    end

    describe 'given --security_group_ids one --security_group_ids two' do
      it { should have_called :create_function, VpcConfig: { SecurityGroupIds: ['one', 'two'] } }
    end

    describe 'given --dead_letter_arn arn' do
      it { should have_called :create_function, DeadLetterConfig: { TargetArn: 'arn' } }
    end

    describe 'given --tracing_mode Active' do
      it { should have_called :create_function, TracingConfig: { Mode: 'Active' } }
    end

    describe 'given --environment_variables ONE=one --environment_variables TWO=two' do
      it { should have_called :create_function, Environment: { Variables: { ONE: 'one', TWO: 'two' } } }
    end

    describe 'given --kms_key_arn arn' do
      it { should have_called :create_function, KMSKeyArn: 'arn' }
    end

    describe 'given --function_tags key=value' do
      it { should have_called :create_function, Tags: { key: 'value' } }
    end
  end

  describe 'function exists' do
    let(:required) { %w(--access_key_id id --secret_access_key key --function_name func) }
    let(:exists) { true }

    before { subject.run }

    describe 'by default' do
      it { should have_run '[info] Using Access Key: i*******************' }
      it { should have_run '[info] Updating existing function func.' }
      it { should have_run '[info] Updating code.' }

      it { should have_called :update_function_config, Runtime: 'nodejs8.10' }
      it { should have_called :update_function_config, Description: 'Deploy build 1 to AWS Lambda via Travis CI' }
      it { should have_called :update_function_config, Timeout: 3 }
      it { should have_called :update_function_config, MemorySize: 128 }
      it { should have_called :update_function_config, TracingConfig: { Mode: 'PassThrough' } }
      it { should have_called :update_function_code, ZipFile: kind_of(String), Publish: false }
    end

    describe 'given --role role' do
      it { should have_called :update_function_config, Role: 'role' }
    end

    describe 'given --handler_name handler' do
      it { should have_called :update_function_config, Handler: 'index.handler' }
    end

    describe 'given --module_name other --handler_name handler' do
      it { should have_called :update_function_config, Handler: 'other.handler' }
    end

    describe 'given --description other' do
      it { should have_called :update_function_config, Description: 'other' }
    end

    describe 'given --timeout 1' do
      it { should have_called :update_function_config, Timeout: 1 }
    end

    describe 'given --memory_size 64' do
      it { should have_called :update_function_config, MemorySize: 64 }
    end

    describe 'given --runtime python2.7' do
      it { should have_called :update_function_config, Runtime: 'python2.7' }
    end

    describe 'given --subnet_ids one --subnet_ids two' do
      it { should have_called :update_function_config, VpcConfig: { SubnetIds: ['one', 'two'] } }
    end

    describe 'given --security_group_ids one --security_group_ids two' do
      it { should have_called :update_function_config, VpcConfig: { SecurityGroupIds: ['one', 'two'] } }
    end

    describe 'given --dead_letter_arn arn' do
      it { should have_called :update_function_config, DeadLetterConfig: { TargetArn: 'arn' } }
    end

    describe 'given --tracing_mode Active' do
      it { should have_called :update_function_config, TracingConfig: { Mode: 'Active' } }
    end

    describe 'given --environment_variables ONE=one --environment_variables TWO=two' do
      it { should have_called :update_function_config, Environment: { Variables: { ONE: 'one', TWO: 'two' } } }
    end

    describe 'given --kms_key_arn arn' do
      it { should have_called :update_function_config, KMSKeyArn: 'arn' }
    end

    describe 'given --publish' do
      it { should have_called :update_function_code, Publish: true }
    end

    describe 'given --function_tags key=value' do
      it { should have_called :tag_resource, Tags: { key: 'value' } }
    end

    describe 'given --layers one --layers two' do
      it { should have_called :update_function_config, Layers: %w(one two) }
    end
  end

  describe 'with ~/.aws/credentials' do
    let(:args) { |e| %w(--function_name func --role role --handler_name handler) }
    let(:exists) { false }

    file '~/.aws/credentials', <<-str.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    str

    before { subject.run }
    it { should have_run '[info] Using Access Key: ac******************' }
  end

  describe 'with ~/.aws/config' do
    let(:args) { |e| %w(--access_key_id id --secret_access_key secret) }

    file '~/.aws/config', <<-str.sub(/^\s*/, '')
      [default]
      function_name=func
      handler_name=handler
      role=role
    str

    before { subject.run }
    it { should have_called :create_function, FunctionName: 'func' }
    it { should have_called :create_function, Role: 'role' }
    it { should have_called :create_function, Handler: 'index.handler' }
  end
end
