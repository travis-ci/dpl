require 'spec_helper'
require 'aws-sdk'
require 'dpl/provider'
require 'dpl/provider/ops_works'

describe DPL::Provider::OpsWorks do

  before (:each) do
    AWS.stub!
  end

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz', :bucket => 'my-bucket')
  end

  describe "#check_auth" do
    example do
      expect(provider).to receive(:setup_auth)
      expect(provider).to receive(:log).with('Logging in with Access Key: ****************jklz')
      provider.check_auth
    end
  end

  describe "#setup_auth" do
    example do
      expect(AWS).to receive(:config).with(:access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz').once.and_call_original
      provider.setup_auth
    end
  end

  describe "#needs_key?" do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe "#push_app" do
    let(:client) { double(:ops_works_client) }
    let(:ops_works_app) { {shortname: 'app', stack_id: 'stack-id'} }
    before do
      expect(provider).to receive(:current_sha).and_return('sha')
      expect(provider.api).to receive(:client).and_return(client)
      expect(ENV).to receive(:[]).with('TRAVIS_BUILD_NUMBER').and_return('123')
    end

    let(:custom_json) { "{\"deploy\":{\"app\":{\"migrate\":false,\"scm\":{\"revision\":\"sha\"}}}}" }
    example 'without :migrate option' do
      provider.options.update(app_id: 'app-id')
      expect(client).to receive(:describe_apps).with(app_ids: ['app-id']).and_return({apps: [ops_works_app]}
      )
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
  end

  describe "#api" do
    example do
      expect(AWS::OpsWorks).to receive(:new)
      provider.api
    end
  end
end
