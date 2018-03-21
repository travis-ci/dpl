require 'spec_helper'
require 'aws-sdk'
require 'dpl/provider'
require 'dpl/provider/ops_works'

describe DPL::Provider::OpsWorks do

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz')
  end

  describe '#opsworks_options' do
    context 'without region' do
      example do
        options = provider.opsworks_options
        expect(options[:region]).to eq('us-east-1')
      end
    end

    context 'with region' do
      example do
        region = 'us-west-1'
        provider.options.update(:region => region)
        options = provider.opsworks_options
        expect(options[:region]).to eq(region)
      end
    end
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:log).with('Logging in with Access Key: ****************jklz')
      provider.check_auth
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe DPL::Provider::OpsWorks do
    access_key_id = 'someaccesskey'
    secret_access_key = 'somesecretaccesskey'
    region = 'us-east-1'

    client_options = {
      stub_responses: true,
      region: region,
      credentials: Aws::Credentials.new(access_key_id, secret_access_key)
    }

    subject :provider do
      described_class.new(DummyContext.new, {
        access_key_id: access_key_id,
        secret_access_key: secret_access_key
      })
    end

    before :each do
      expect(provider).to receive(:opsworks_options).and_return(client_options)
    end

    describe '#opsworks' do
      example do
        expect(Aws::OpsWorks::Client).to receive(:new).with(client_options).once
        provider.opsworks
      end
    end

    describe "#push_app" do
      let(:client) { provider.opsworks }
      let(:ops_works_app) { {shortname: 'app', stack_id: 'stack-id'} }
      before do
        expect(provider).to receive(:current_sha).and_return('sha')
        expect(provider.context.env).to receive(:[]).with('TRAVIS_BUILD_NUMBER').and_return('123')
      end

      let(:custom_json) { "{\"deploy\":{\"app\":{\"migrate\":false,\"scm\":{\"revision\":\"sha\"}}}}" }
      example 'without :migrate option' do
        provider.options.update(app_id: 'app-id')
        expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]})
        expect(client).to receive(:create_deployment).with(
          stack_id: 'stack-id', app_id: 'app-id', command: {name: 'deploy'}, comment: 'Deploy build 123 via Travis CI', custom_json: custom_json
        ).and_return({})
        provider.push_app
      end

      let(:custom_json_with_migrate) { "{\"deploy\":{\"app\":{\"migrate\":true,\"scm\":{\"revision\":\"sha\"}}}}" }
      example 'with :migrate option' do
        provider.options.update(app_id: 'app-id', migrate: true)
        expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]})
        expect(client).to receive(:create_deployment).with(
          stack_id: 'stack-id', app_id: 'app-id', command: {name: 'deploy'}, comment: 'Deploy build 123 via Travis CI', custom_json: custom_json_with_migrate
        ).and_return({})
        provider.push_app
      end

      example 'with :wait_until_deployed' do
        provider.options.update(app_id: 'app-id', wait_until_deployed: true)
        expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]})
        expect(client).to receive(:create_deployment).and_return({deployment_id: 'deployment_id'})
        expect(client).to receive(:describe_deployments).with({deployment_ids: ['deployment_id']}).and_return({deployments: [status: 'running']}, {deployments: [status: 'successful']})
        provider.push_app
      end

      example 'with :wait_until_deployed and :update_app_on_success' do
        provider.options.update(app_id: 'app-id', wait_until_deployed: 'true', update_app_on_success: 'true')
        expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]})
        expect(client).to receive(:create_deployment).and_return({deployment_id: 'deployment_id'})
        expect(client).to receive(:describe_deployments).with({deployment_ids: ['deployment_id']}).and_return({deployments: [status: 'running']}, {deployments: [status: 'successful']})
        expect(provider).to receive(:update_app).and_return(true)

        provider.push_app
      end

      example 'with :instance-ids' do
        provider.options.update(app_id: 'app-id', instance_ids: ['instance-id'])
        expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]})
        expect(client).to receive(:create_deployment).with(
          stack_id: 'stack-id', app_id: 'app-id', instance_ids:['instance-id'], command: {name: 'deploy'}, comment: 'Deploy build 123 via Travis CI', custom_json: custom_json
        ).and_return({})
        provider.push_app
      end

      example 'with :layer-ids' do
        provider.options.update(app_id: 'app-id', layer_ids: ['layer-id'])
        expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]})
        expect(client).to receive(:create_deployment).with(
          stack_id: 'stack-id', app_id: 'app-id', layer_ids:['layer-id'], command: {name: 'deploy'}, comment: 'Deploy build 123 via Travis CI', custom_json: custom_json
        ).and_return({})
        provider.push_app
      end
    end
  end
end
