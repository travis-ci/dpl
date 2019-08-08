describe Dpl::Providers::Codedeploy do
  let(:args) { |e| %w(--access_key_id id --secret_access_key key --application app) + args_from_description(e) }
  let(:requests) { Hash.new { |hash, key| hash[key] = [] } }

  env TRAVIS_BUILD_NUMBER: 1

  before do
    Aws.config[:s3] = {
      stub_responses: {
        get_object: ->(ctx) {
          requests[:buckets] << ctx.http_request
          { deployment_id: 'id' }
        }
      }
    }
    Aws.config[:codedeploy] = {
      stub_responses: {
        create_deployment: ->(ctx) {
          requests[:create_deployment] << ctx.http_request
          { deployment_id: 'id' }
        },
        get_deployment: ->(ctx) {
          requests[:get_deployment] << ctx.http_request
          { deployment_info: { status: 'Succeeded' } }
        }
      }
    }
  end

  after { Aws.config.clear }

  matcher :create_deployment do |params = {}|
    match do |*|
      next false unless request = requests[:create_deployment][0]
      body = symbolize(JSON.parse(request.body.read))
      params.all? { |key, value| body[key] == value }
    end
  end

  matcher :get_deployment do |*|
    match { |*| requests[:get_deployment].any? }
  end

  before { subject.run }

  let(:github_revision) { { revisionType: 'GitHub', gitHubLocation: { repository: 'dpl', commitId: 'sha' } } }
  let(:s3_revision) { { revisionType: 'S3', s3Location: { bucket: 'bucket', bundleType: 'zip', version: 'ObjectVersionId', eTag: 'ETag' } } }

  describe 'by default', record: true do
    it { should have_run '[info] Using Access Key: i*******************' }
    it { should create_deployment applicationName: 'app' }
    it { should create_deployment description: 'Deploy build 1 via Travis CI' }
    it { should create_deployment revision: github_revision }
    it { should have_run '[info] Deployment triggered: id' }
    it { should have_run_in_order }
  end

  describe 'given --deployment_group group' do
    it { should create_deployment deploymentGroupName: 'group' }
  end

  describe 'given --revision_type github' do
    it { should create_deployment revision: github_revision }
  end

  describe 'given --revision_type GitHub' do
    it { should create_deployment revision: github_revision }
  end

  describe 'given --commit_id other' do
    before { github_revision[:gitHubLocation][:commitId] = 'other' }
    it { should create_deployment revision: github_revision }
  end

  describe 'given --repository other' do
    before { github_revision[:gitHubLocation][:repository] = 'other' }
    it { should create_deployment revision: github_revision }
  end

  describe 'given --revision_type s3 --bucket bucket --key bundle.zip' do
    before { s3_revision[:s3Location][:key] = 'bundle.zip' }
    it { should create_deployment revision: s3_revision }
  end

  describe 'given --revision_type s3 --bucket other --key bundle.zip' do
    before { s3_revision[:s3Location].update(key: 'bundle.zip', bucket: 'other') }
    it { should create_deployment revision: s3_revision }
  end

  describe 'given --revision_type s3 --bucket bucket --key other --bundle_type other' do
    before { s3_revision[:s3Location].update(key: 'other', bundleType: 'other') }
    it { should create_deployment revision: s3_revision }
  end

  describe 'given --wait_until_deployed' do
    it { should create_deployment revision: github_revision }
    it { should have_run '[print] Waiting for the deployment to finish ' }
    it { should get_deployment }
  end
end
