# frozen_string_literal: true

describe Dpl::Providers::Codedeploy do
  include Support::Matchers::Aws

  let(:args) { |e| %w[--access_key_id access_key_id --secret_access_key secret_access_key --application app] + args_from_description(e) }
  let(:github_revision) { { revisionType: 'GitHub', gitHubLocation: { repository: 'dpl', commitId: 'sha' } } }
  let(:s3_revision) { { revisionType: 'S3', s3Location: { bucket: 'bucket', bundleType: 'zip', version: 'ObjectVersionId', eTag: 'ETag' } } }
  let(:client) { Aws::CodeDeploy::Client.new(stub_responses: responses[:eb]) }
  let(:s3)     { Aws::S3::Client.new(stub_responses: true) }

  let(:responses) do
    {
      eb: {
        create_deployment: {
          deployment_id: 'deployment_id'
        },
        get_deployment: {
          deployment_info: { status: 'Succeeded' }
        }
      }
    }
  end

  let(:github_revision) { { revisionType: 'GitHub', gitHubLocation: { repository: 'dpl', commitId: 'sha' } } }
  let(:s3_revision) { { revisionType: 'S3', s3Location: { bucket: 'bucket', bundleType: 'zip', version: 'ObjectVersionId', eTag: 'ETag' } } }

  env TRAVIS_BUILD_NUMBER: 1

  before { allow(Aws::CodeDeploy::Client).to receive(:new).and_return(client) }
  before { allow(Aws::S3::Client).to receive(:new).and_return(s3) }
  before { |c| subject.run if run?(c) }

  before { |c| subject.run unless c.metadata[:run].is_a?(FalseClass) }
  after { Aws.config.clear }

  describe 'by default', record: true do
    it { is_expected.to have_run '[info] Using Access Key: ac******************' }
    it { is_expected.to create_deployment applicationName: 'app' }
    it { is_expected.to create_deployment description: 'Deploy build 1 via Travis CI' }
    it { is_expected.to create_deployment revision: github_revision }
    it { is_expected.to create_deployment fileExistsBehavior: 'DISALLOW' }
    it { is_expected.to have_run '[info] Deployment triggered: deployment_id' }
    it { is_expected.to have_run_in_order }
  end

  describe 'given --deployment_group group' do
    it { is_expected.to create_deployment deploymentGroupName: 'group' }
  end

  describe 'given --revision_type github' do
    it { is_expected.to create_deployment revision: github_revision }
  end

  describe 'given --revision_type GitHub' do
    it { is_expected.to create_deployment revision: github_revision }
  end

  describe 'given --commit_id other' do
    before { github_revision[:gitHubLocation][:commitId] = 'other' }

    it { is_expected.to create_deployment revision: github_revision }
  end

  describe 'given --repository other' do
    before { github_revision[:gitHubLocation][:repository] = 'other' }

    it { is_expected.to create_deployment revision: github_revision }
  end

  describe 'given --revision_type s3 --bucket bucket --key bundle.zip' do
    before { s3_revision[:s3Location][:key] = 'bundle.zip' }

    it { is_expected.to create_deployment revision: s3_revision }
  end

  describe 'given --revision_type s3 --bucket other --key bundle.zip' do
    before { s3_revision[:s3Location].update(key: 'bundle.zip', bucket: 'other') }

    it { is_expected.to create_deployment revision: s3_revision }
  end

  describe 'given --revision_type s3 --bucket bucket --key other --bundle_type other' do
    before { s3_revision[:s3Location].update(key: 'other', bundleType: 'other') }

    it { is_expected.to create_deployment revision: s3_revision }
  end

  describe 'given --wait_until_deployed' do
    it { is_expected.to create_deployment revision: github_revision }
    it { is_expected.to have_run '[print] Waiting for the deployment to finish ' }
    it { is_expected.to get_deployment }
  end

  describe 'given --wait_until_deployed', run: false do
    let(:responses) do
      {
        eb: {
          get_deployment: {
            deployment_info: { status: 'Failed' }
          }
        }
      }
    end

    it { expect { subject.run }.to raise_error(/Failed/) }
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { |_e| %w[--application app] }

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
      application=app
      revision_type=s3
      bucket=bucket
      key=bundle.zip
    STR

    before { s3_revision[:s3Location][:key] = 'bundle.zip' }
    before { subject.run }

    it { is_expected.to create_deployment revision: s3_revision }
  end
end
