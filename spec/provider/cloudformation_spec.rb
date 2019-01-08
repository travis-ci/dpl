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
                        stack_name: "some-test-stack-name")
  end

  before :each do
    allow(provider).to receive(:cf_options).and_return(client_options)
    # allow_any_instance_of(::Aws::CloudFormation::).to receive(:upload_file).and_return(true)
    allow(provider).to receive(:log).with(anything).and_return(true)
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
      provider.options.update(filepath: "some-non-existing.yml")
      allow(File).to receive(:exist?).with("some-non-existing.yml").and_return(false)
      expect { provider.filepath }.to raise_error(DPL::Error)
    end

    it 'should return filepath when given' do
      allow(File).to receive(:exist?).with("some-existing.yml").and_return(true)
      provider.options.update(filepath: "some-existing.yml")
      expect(provider.filepath).to eq("some-existing.yml")
    end
  end

  describe '#needs_key?' do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe '#push_app' do
    it 'should execute with proper values' do
      Tempfile.create("cf.yml") do |t|
        t.write('some: This is a thing!')
        t.size # Flush file
        expect(provider).to receive(:stack_name)
        expect(provider).to receive(:template_body)
        expect(provider.stack_name).to eq("some-test-stack-name")
        expect(provider.template_body).to eq("some: This is a thing!")

        provider.push_app
      end
    end
  end
end
