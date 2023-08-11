# frozen_string_literal: true

describe Dpl::Providers::Opsworks do
  include Support::Matchers::Aws

  let(:args)   { |e| %w[--access_key_id access_key_id --secret_access_key secret_access_key --app_id app] + args_from_description(e) }
  let(:client) { Aws::OpsWorks::Client.new(stub_responses: responses) }

  let(:responses) do
    {
      describe_apps: {
        apps: [stack_id: 'stack_id', shortname: 'dpl']
      },
      create_deployment: {
        deployment_id: 'id'
      },
      describe_deployments: {
        deployments: [status: 'successful']
      },
      update_app: {}
    }
  end

  before { allow(Aws::OpsWorks::Client).to receive(:new).and_return(client) }
  before { |c| subject.run if run?(c) }

  describe 'by default', record: true do
    let(:json) { JSON.dump(deploy: { dpl: { migrate: false, scm: { revision: 'sha' } } }) }

    it { is_expected.to have_run '[info] Using Access Key: ac******************' }
    it { is_expected.to have_run '[print] Creating deployment ... ' }
    it { is_expected.to have_run '[info] Done: id' }
    it { is_expected.to have_run_in_order }

    it { is_expected.to create_deployment StackId: 'stack_id' }
    it { is_expected.to create_deployment AppId: 'app' }
    it { is_expected.to create_deployment Command: { Name: 'deploy' } }
    it { is_expected.to create_deployment Comment: 'Deploy build 1 via Travis CI' }
    it { is_expected.to create_deployment CustomJson: json }
  end

  describe 'given --instance_ids one --instance_ids two' do
    it { is_expected.to create_deployment InstanceIds: %w[one two] }
  end

  describe 'given --layer_ids one --layer_ids two' do
    it { is_expected.to create_deployment LayerIds: %w[one two] }
  end

  describe 'given --migrate' do
    let(:json) { JSON.dump(deploy: { dpl: { migrate: true, scm: { revision: 'sha' } } }) }

    it { is_expected.to create_deployment CustomJson: json }
  end

  describe 'given --custom_json danger:will-robinson' do
    it { is_expected.to create_deployment CustomJson: 'danger:will-robinson' }
  end

  describe 'given --wait_until_deployed' do
    it { is_expected.to have_run '[print] Deploying ' }
    it { is_expected.to describe_deployments DeploymentIds: ['id'] }
  end

  describe 'given --wait_until_deployed --update_on_success' do
    it { is_expected.to update_app AppId: 'app', AppSource: { Revision: 'sha' } }
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { |_e| %w[--app_id app] }
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

    file '~/.aws/config', <<-STR.sub(/^\s*/, '')
      [default]
      app_id=app
    STR

    before { subject.run }

    it { is_expected.to create_deployment AppId: 'app' }
  end
end
