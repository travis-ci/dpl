# frozen_string_literal: true

describe Dpl::Providers::Elasticbeanstalk do
  include Support::Matchers::Aws

  let(:args) { |e| required + args_from_description(e) }
  let(:required) { %w[--access_key_id id --secret_access_key key --bucket bucket] }
  let(:events) { [] }

  let(:client)   { Aws::ElasticBeanstalk::Client.new(stub_responses: responses) }
  let(:s3)       { Aws::S3::Client.new(stub_responses: true) }
  let(:events)   { [] }

  let(:responses) do
    {
      create_application_version: {
        application_version: {
          version_label: 'label'
        }
      },
      update_environment: {},
      describe_environments: {
        environments: [
          status: 'Ready'
        ]
      },
      describe_events: {
        events:
      }
    }
  end

  file 'one'
  file 'two'

  before { allow(Aws::ElasticBeanstalk::Client).to receive(:new).and_return(client) }
  before { allow(Aws::S3::Client).to receive(:new).and_return(s3) }
  before { |c| subject.run if run?(c) }

  describe 'by default' do
    before { subject.run }

    it { is_expected.to have_zipped "travis-sha-#{now.to_i}.zip", %w[one two] }
    it { is_expected.to have_run '[info] Using Access Key: i*******************' }
    it { is_expected.to create_app_version 'ApplicationName=dpl' }
    it { is_expected.to create_app_version 'Description=commit%20msg' }
    it { is_expected.to create_app_version 'S3Bucket=bucket' }
    it { is_expected.to create_app_version /S3Key=travis-sha-.*.zip/ }
    it { is_expected.to create_app_version /VersionLabel=travis-sha.*/ }
    it { is_expected.not_to update_environment }
  end

  describe 'given --env env' do
    before { subject.run }

    it { is_expected.to create_app_version }
    it { is_expected.to update_environment }
  end

  describe 'given --bucket_path one/two' do
    before { subject.run }

    it { is_expected.to create_app_version /S3Key=one%2Ftwo%2Ftravis-sha-.*.zip/ }
  end

  describe 'given --description description' do
    before { subject.run }

    it { is_expected.to create_app_version 'Description=description' }
  end

  describe "given --description description\u0020a (non-printable chars)" do
    let(:args) { required + %w[--description description\u0020] }

    before { subject.run }

    it { is_expected.to create_app_version 'Description=description' }
  end

  describe 'given --label label' do
    before { subject.run }

    it { is_expected.to create_app_version 'VersionLabel=label' }
  end

  describe 'given --zip_file other.zip' do
    before { subject.run }

    it { expect(File.exist?('other.zip')).to be true }
    it { is_expected.to create_app_version /S3Key=travis-sha-.*.zip/ }
  end

  describe 'given --env env --wait_until_deployed', run: false do
    let(:events) { [event_date: Time.now, severity: 'ERROR', message: 'msg'] }

    it { expect { subject.run }.to raise_error /Deployment failed/ }
  end

  describe 'with an .ebignore file', run: false do
    file '.ebignore', "*\n!one"
    before { subject.run }

    it { is_expected.to have_zipped "travis-sha-#{now.to_i}.zip", %w[one] }
  end

  describe 'with a .gitignore file', run: false do
    file '.gitignore', "*\n!one"
    before { subject.run }

    it { is_expected.to have_zipped "travis-sha-#{now.to_i}.zip", %w[one] }
  end

  describe 'with both an .ebignore and .gitignore file', run: false do
    file '.ebignore', "*\n!one"
    file '.gitignore', '*'
    before { subject.run }

    it { is_expected.to have_zipped "travis-sha-#{now.to_i}.zip", %w[one] }
  end

  describe 'with ~/.aws/credentials', run: false do
    let(:args) { |e| %w[--env env --bucket_name bucket] }

    file '~/.aws/credentials', <<-STR.sub(/^\s*/, '')
      [default]
      aws_access_key_id=access_key_id
      aws_secret_access_key=secret_access_key
    STR

    before { subject.run }

    it { is_expected.to have_run '[info] Using Access Key: ac******************' }
  end

  describe 'with ~/.aws/config', run: false do
    let(:args) { |e| %w[--access_key_id id --secret_access_key secret] }

    file '~/.aws/config', <<-STR.sub(/^\s*/, '')
      [default]
      env=env
      bucket=bucket
    STR

    before { subject.run }

    it { is_expected.to create_app_version 'S3Bucket=bucket' }
  end
end
