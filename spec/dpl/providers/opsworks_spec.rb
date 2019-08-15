describe Dpl::Providers::Opsworks do
  let(:args) { |e| %w(--access_key_id id --secret_access_key key --app_id app) + args_from_description(e) }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }

  matcher :have_called do |key, params = {}|
    match do |*|
      @body = symbolize(JSON.parse(requests[key][0].body.read)) if requests[key].any?
      @body ? expect(@body).to(include(params)) : false
    end

    failure_message do
      "Expected it to have called #{key.inspect}\n\n  #{params.inspect}\n\nbut it was not. Instead it was called with:\n\n  #{@body}"
    end
  end

  before do
    Aws.config[:opsworks] = {
      stub_responses: {
        describe_apps: ->(ctx) {
          requests[:describe_apps] << ctx.http_request
          { apps: [stack_id: 'stack_id', shortname: 'dpl'] }
        },
        create_deployment: ->(ctx) {
          requests[:create_deployment] << ctx.http_request
          { deployment_id: 'id' }
        },
        describe_deployments: ->(ctx) {
          requests[:describe_deployments] << ctx.http_request
          { deployments: [status: 'successful'] }
        },
        update_app: ->(ctx) {
          requests[:update_app] << ctx.http_request
        }
      }
    }
  end

  after { Aws.config.clear }

  context do
    before { subject.run }

    describe 'by default', record: true do
      let(:json) { JSON.dump(deploy: { dpl: { migrate: false, scm: { revision: 'sha' } } }) }

      it { should have_run '[info] Using Access Key: i*******************' }
      it { should have_run '[print] Creating deployment ... ' }
      it { should have_run '[info] Done: id' }
      it { should have_run_in_order }

      it do
        should have_called :create_deployment, {
          StackId: 'stack_id',
          AppId: 'app',
          Command: { Name: 'deploy' },
          Comment: 'Deploy build 1 via Travis CI',
          CustomJson: json
        }
      end
    end

    describe 'given --instance_ids one --instance_ids two' do
      it { should have_called :create_deployment, InstanceIds: ['one', 'two'] }
    end

    describe 'given --layer_ids one --layer_ids two' do
      it { should have_called :create_deployment, LayerIds: ['one', 'two'] }
    end

    describe 'given --migrate' do
      let(:json) { JSON.dump(deploy: { dpl: { migrate: true, scm: { revision: 'sha' } } }) }
      it { should have_called :create_deployment, CustomJson: json }
    end

    describe 'given --custom_json danger:will-robinson' do
      it { should have_called :create_deployment, CustomJson: 'danger:will-robinson' }
    end

    describe 'given --wait_until_deployed' do
      it { should have_run '[print] Deploying ' }
      it { should have_called :describe_deployments, DeploymentIds: ['id'] }
    end

    describe 'given --wait_until_deployed --update_on_success' do
      it { should have_called :update_app, AppId: 'app', AppSource: { Revision: 'sha' } }
    end
  end

  describe 'with ~/.aws/credentials' do
    let(:args) { |e| %w(--app_id app) }
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
      app_id=app
    str

    before { subject.run }
    it { should have_called :create_deployment, AppId: 'app' }
  end
end
