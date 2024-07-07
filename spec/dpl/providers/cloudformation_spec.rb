# frozen_string_literal: true

describe Dpl::Providers::Cloudformation do
  let(:args) { |e| required + args_from_description(e) }
  let(:required) { %w[--access_key_id id --secret_access_key key --stack_name stack --template https://template.url] }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }
  let(:stacks) { [] }
  let(:events) { [] }

  %i[create_stack update_stack create_change_set].each do |key|
    matcher key do |opts = {}|
      match do |*|
        next false unless requests[key].any?
        next true unless opts[:with]

        @body = requests[key][0].body.read
        opts[:with].is_a?(Regexp) ? @body =~ opts[:with] : @body.include?(opts[:with])
      end

      failure_message do
        msg = "Expected #{key} to be called with:\n\n  #{opts[:with]}\n\nbut it was not."
        msg = "#{msg} Instead it was called with:\n\n  #{@body}" if @body
        msg
      end
    end
  end

  before do
    Aws.config[:cloudformation] = {
      stub_responses: {
        create_stack: lambda { |ctx|
          requests[:create_stack] << ctx.http_request
        },
        update_stack: lambda { |ctx|
          requests[:update_stack] << ctx.http_request
        },
        create_change_set: lambda { |ctx|
          requests[:create_change_set] << ctx.http_request
          {
            id: 'id',
            stack_id: 'stack_id'
          }
        },
        delete_change_set: lambda { |ctx|
          requests[:delete_change_set] << ctx.http_request
        },
        describe_stacks: {
          stacks:
        },
        describe_stack_events: {
          stack_events: [
            stack_id: 'id',
            stack_name: 'stack',
            event_id: '1',
            timestamp: Time.now
          ]
        },
        describe_change_set: {}
      }
    }
  end

  before { |c| subject.run unless c.metadata[:run].is_a?(FalseClass) }

  after { Aws.config.clear }

  env ONE: '1'

  file 'one'
  file 'two'
  file 'template.json', '{}'

  describe 'stack does not exist' do
    let(:stacks) { [] }

    describe 'by default' do
      it { is_expected.to have_run '[info] Using Access Key: i*******************' }
      it { is_expected.to have_run '[info] Setting the build environment up for the deployment' }
      it { is_expected.to have_run '[info] Creating stack ...' }
      it { is_expected.to create_stack with: 'Action=CreateStack&OnFailure=ROLLBACK&Parameters=&StackName=stack&TemplateURL=https%3A%2F%2Ftemplate.url&TimeoutInMinutes=60' }
    end

    describe 'given --no-promote' do
      it { is_expected.to create_change_set with: /Action=CreateChangeSet&ChangeSetName=travis-ci-build-1-.*&ChangeSetType=CREATE&Description=Changeset%20created%20by%20Travis%20CI.*&Parameters=&StackName=stack/ }
    end

    describe 'given --stack_name_prefix prefix-' do
      it { is_expected.to create_stack with: 'Action=CreateStack&OnFailure=ROLLBACK&Parameters=&StackName=prefix-stack' }
    end

    describe 'given --role_arn arn' do
      it { is_expected.to create_stack with: 'Action=CreateStack&OnFailure=ROLLBACK&Parameters=&RoleARN=arn&StackName=stack' }
    end

    describe 'given --capabilities CAPABILITY_IAM --capabilities CAPABILITY_NAMED_IAM' do
      it { is_expected.to create_stack with: 'Action=CreateStack&Capabilities.member.1=CAPABILITY_IAM&Capabilities.member.2=CAPABILITY_NAMED_IAM&OnFailure=ROLLBACK&Parameters=&StackName=stack' }
    end

    describe 'given --capabilities CAPABILITY_IAM,CAPABILITY_NAMED_IAM' do
      it { is_expected.to create_stack with: 'Action=CreateStack&Capabilities.member.1=CAPABILITY_IAM&Capabilities.member.2=CAPABILITY_NAMED_IAM&OnFailure=ROLLBACK&Parameters=&StackName=stack' }
    end

    describe 'given --parameters ONE --parameters two=2' do
      it { is_expected.to create_stack with: 'Action=CreateStack&OnFailure=ROLLBACK&Parameters.member.1.ParameterKey=ONE&Parameters.member.1.ParameterValue=1&Parameters.member.2.ParameterKey=two&Parameters.member.2.ParameterValue=2&StackName=stack' }
    end
  end

  describe 'stack exists' do
    let(:stacks) do
      [
        stack_id: 'id',
        stack_name: 'name',
        creation_time: Time.now,
        stack_status: 'CREATE_COMPLETE',
        outputs: [
          {
            output_key: 'key',
            output_value: 'value'
          }
        ]
      ]
    end

    describe 'by default' do
      it { is_expected.to have_run '[info] Using Access Key: i*******************' }
      it { is_expected.to have_run '[info] Setting the build environment up for the deployment' }
      it { is_expected.to have_run '[info] Promoting stack ...' }
      it { is_expected.to update_stack with: 'Action=UpdateStack&Parameters=&StackName=stack' }
    end

    describe 'given --no-promote' do
      it { is_expected.to create_change_set with: /Action=CreateChangeSet&ChangeSetName=travis-ci-build-1-.*&ChangeSetType=UPDATE&Description=Changeset%20created%20by%20Travis%20CI.*&Parameters=&StackName=stack/ }
    end

    describe 'given --stack_name_prefix prefix-' do
      it { is_expected.to update_stack with: 'Action=UpdateStack&Parameters=&StackName=prefix-stack' }
    end

    describe 'given --role_arn arn' do
      it { is_expected.to update_stack with: 'Action=UpdateStack&Parameters=&RoleARN=arn&StackName=stack' }
    end

    describe 'given --capabilities CAPABILITY_IAM,CAPABILITY_NAMED_IAM' do
      it { is_expected.to update_stack with: 'Action=UpdateStack&Capabilities.member.1=CAPABILITY_IAM&Capabilities.member.2=CAPABILITY_NAMED_IAM&Parameters=&StackName=stack' }
    end

    describe 'given --output_file ./events.log' do
      it { expect(File.read('events.log')).to eq 'key=value' }
    end
  end

  describe 'with AWS credentials in env vars', run: false do
    env AWS_ACCESS_KEY_ID: 'id',
        AWS_SECRET_ACCESS_KEY: 'key'

    before { subject.run }

    it { is_expected.to have_run '[info] Using Access Key: i*******************' }
  end

  describe 'with CLOUDFORMATION credentials in env vars', run: false do
    env CLOUDFORMATION_ACCESS_KEY_ID: 'id',
        CLOUDFORMATION_SECRET_ACCESS_KEY: 'key'

    before { subject.run }

    it { is_expected.to have_run '[info] Using Access Key: i*******************' }
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { %w[--stack_name stack --template https://template.url] }

    file '~/.aws/credentials', <<-STR.sub(/^\s*/, '')
      [default]
      aws_access_key_id=id
      aws_secret_access_key=key
    STR

    before { subject.run }

    it { is_expected.to have_run '[info] Using Access Key: i*******************' }
  end
end
