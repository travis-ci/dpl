# frozen_string_literal: true

require 'spec_helper'
require 'dpl/provider/cloudformation'

describe DPL::Provider::CloudFormation do
  subject :provider do
    described_class.new(DummyContext.new, access_key_id: 'qwertyuiopasdfghjklz', secret_access_key: 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz')
  end

  describe '#cf_options' do
    context 'without region' do
      example do
        options = provider.cf_options
        expect(options[:region]).to eq('us-east-1')
      end
    end

    context 'with region' do
      example do
        region = 'us-west-1'
        provider.options.update(region: region)
        options = provider.cf_options
        expect(options[:region]).to eq(region)
      end
    end
  end
end

describe DPL::Provider::CloudFormation do
  access_key_id = 'qwertyuiopasdfghjklz'
  secret_access_key = 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz'
  region = 'us-east-1'

  client_options = {
    stub_responses: true,
    region: region,
    credentials: Aws::Credentials.new(access_key_id, secret_access_key)
  }

  subject :provider do
    described_class.new(DummyContext.new,
                        access_key_id: access_key_id,
                        secret_access_key: secret_access_key,
                        stack_name: 'some-test-stack-name')
  end

  before :each do
    allow(provider).to receive(:cf_options).and_return(client_options)
    # allow_any_instance_of(::Aws::CloudFormation::).to receive(:upload_file).and_return(true)
    allow(provider).to receive(:log).with(anything).and_return(true) # TODO: ???
    allow(provider.client).to receive(:wait_until).and_return(true)
    provider.options.update(template_url: 's3://template-url')
  end

  describe '#check_auth' do
    example do
      expect(provider).to receive(:log).with('Logging in with Access Key: ****************jklz')
      provider.check_auth
    end
  end

  describe '#filepath' do
    it 'should raise an error on missing filepath' do
      expect { provider.filepath }.to raise_error(DPL::Error)
    end

    it 'should raise an error on missing file' do
      provider.options.update(filepath: 'some-non-existing.yml')
      allow(File).to receive(:exist?).with('some-non-existing.yml').and_return(false)
      expect { provider.filepath }.to raise_error(DPL::Error)
    end

    it 'should return filepath when given' do
      allow(File).to receive(:exist?).with('some-existing.yml').and_return(true)
      provider.options.update(filepath: 'some-existing.yml')
      expect(provider.filepath).to eq('some-existing.yml')
    end
  end

  describe '#needs_key?' do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe '#common_parameters' do
    it 'should use role_arn if provided' do
      provider.options.update(role_arn: 'arn:::my/roleArn')
      expect(provider.common_parameters).to have_key(:role_arn)
      expect(provider.common_parameters[:role_arn]).to eq('arn:::my/roleArn')
    end

    it 'should fail if neither filepath nor template_url is set' do
      provider.options.delete(:template_url)
      provider.options.delete(:filepath)
      expect { provider.filepath }.to raise_error(DPL::Error, /Missing file path/)
    end

    it 'should use template_body if template_url is missing' do
      provider.options.delete(:template_url)
      provider.options.update(filepath: 'some-non-existing.yml')
      allow(provider).to receive(:template_body).and_return('some-body-contents')
      expect(provider.common_parameters).to have_key(:template_body)
      expect(provider.common_parameters).not_to have_key(:template_url)
      expect(provider.common_parameters[:template_body]).to eq('some-body-contents')
    end

    it 'should use template_url over template_body' do
      provider.options.update(filepath: 'some-non-existing.yml')
      provider.options.update(template_url: 's3://URL')
      expect(provider.common_parameters).to have_key(:template_url)
      expect(provider.common_parameters).not_to have_key(:template_body)
      expect(provider.common_parameters[:template_url]).to eq('s3://URL')
    end

    it 'should use capabilities if given' do
      provider.options.update(capabilities: ['some-cap'])
      expect(provider.common_parameters).to have_key(:capabilities)
      expect(provider.common_parameters[:capabilities]).to be_an(Array)
      expect(provider.common_parameters[:capabilities]).to include 'some-cap'
    end

    it 'should wrap capabilities to array if given as string' do
      provider.options.update(capabilities: 'some-cap')
      expect(provider.common_parameters).to have_key(:capabilities)
      expect(provider.common_parameters[:capabilities]).to be_an(Array)
      expect(provider.common_parameters[:capabilities]).to include 'some-cap'
    end
  end

  describe '#push_app' do
    it 'should execute with proper values' do
      provider.options.delete(:template_url)
      provider.options.update(promote: true)
      Tempfile.create('cf.yml') do |t|
        t.write('some: This is a thing!')
        t.size # Flush file
        provider.options.update(filepath: t.path)
        expect(provider.client).to receive(:describe_stacks)
          .with(stack_name: 'some-test-stack-name')
          .and_return([])
        expect(provider.client).to receive(:create_stack)
          .with(hash_including(
                  stack_name: 'some-test-stack-name',
                  template_body: 'some: This is a thing!'
                ))

        provider.push_app
      end
    end

    it 'should run create stack when one does not exist' do
      provider.options.update(promote: true)
      expect(provider.client).to receive(:describe_stacks)
        .with(stack_name: 'some-test-stack-name')
        .and_return([])
      expect(provider.client).to receive(:create_stack).and_return(true)
      provider.push_app
    end

    it 'should run update stack when one does exist' do
      provider.options.update(promote: true)
      expect(provider.client).to receive(:describe_stacks)
        .with(stack_name: 'some-test-stack-name')
        .and_return([{ stack_id: 'some-stack-id' }])
      expect(provider.client).to receive(:update_stack).and_return(true)
      provider.push_app
    end

    it 'should run create change set with type CREATE when stack does not exist' do
      ccs = double
      allow(ccs).to receive(:id) { 'some-changeset-id' }

      provider.options.update(promote: false)
      expect(provider.client).to receive(:describe_stacks)
        .with(stack_name: 'some-test-stack-name')
        .and_return([])
      expect(provider.client).to receive(:create_change_set)
        .with(hash_including(
                stack_name: 'some-test-stack-name',
                change_set_type: 'CREATE'
              ))
        .and_return(ccs)
      provider.push_app
    end

    it 'should run create change set with type UPDATE when stack exists' do
      ccs = double
      allow(ccs).to receive(:id) { 'some-changeset-id' }

      provider.options.update(promote: false)
      expect(provider.client).to receive(:describe_stacks)
        .with(stack_name: 'some-test-stack-name')
        .and_return([{ stack_id: 'some-stack-id' }])
      expect(provider.client).to receive(:create_change_set)
        .with(hash_including(
                stack_name: 'some-test-stack-name',
                change_set_type: 'UPDATE'
              ))
        .and_return(ccs)
      provider.push_app
    end

    it 'should skip event streaming when wait is false' do
      provider.options.update(wait: false)
      expect(provider.client).not_to receive(:wait_until)
      provider.push_app
    end

    it 'should run event streaming when wait is true' do
      provider.options.update(wait: true)
      expect(provider.client).to receive(:wait_until).and_return(true)
      provider.push_app
    end
  end
end

describe DPL::Provider::CloudFormation do
  subject :provider do
    described_class.new(DummyContext.new, {})
  end

  describe '#parameters' do
    it 'should return empty list if no parameters' do
      provider.options.delete(:parameters)
      expect(provider.parameters).to match_array []
    end

    it 'should return single-array parameter if string given' do
      provider.options.update(parameters: 'MyOnlyParameter=IsLonely')
      expect(provider.parameters).to be_an Array
      expect(provider.parameters.size).to eq(1)
      expect(provider.parameters[0]).to eq(
        parameter_key: 'MyOnlyParameter',
        parameter_value: 'IsLonely'
      )
    end

    it 'should return array of parameters if array given' do
      provider.options.update(parameters: [
                                'SomeParam1=AnotherValue1',
                                'Lalala=Lelele',
                                'MyResourceName=IsAwesome'
                              ])
      expect(provider.parameters).to be_an Array
      expect(provider.parameters.size).to eq(3)
      expect(provider.parameters).to include(
        parameter_key: 'SomeParam1',
        parameter_value: 'AnotherValue1'
      )
      expect(provider.parameters).to include(
        parameter_key: 'Lalala',
        parameter_value: 'Lelele'
      )
      expect(provider.parameters).to include(
        parameter_key: 'MyResourceName',
        parameter_value: 'IsAwesome'
      )
    end
  end
end
