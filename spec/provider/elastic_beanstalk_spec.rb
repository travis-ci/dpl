require 'spec_helper'
require 'aws-sdk-v1'
require 'dpl/provider'
require 'dpl/provider/elastic_beanstalk'

describe DPL::Provider::ElasticBeanstalk do

  before (:each) do
    AWS.stub!
  end

  let(:access_key_id) { 'qwertyuiopasdfghjklz' }
  let(:secret_access_key) { 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz' }
  let(:region) { 'us-west-2' }
  let(:app) { 'example-app' }
  let(:env) { 'live' }
  let(:bucket_name) { "travis-elasticbeanstalk-test-builds-#{region}" }
  let(:bucket_path) { "some/app"}
  let(:only_create_app_version) { nil }
  let(:wait_until_deployed) { nil }

  let(:bucket_mock) do
    dbl = double("bucket mock", write: nil)
    allow(dbl).to receive(:objects).and_return(double("Hash", :[] => dbl))
    dbl
  end

  let(:s3_mock) do
    hash_dbl = double("Hash", :[] => bucket_mock, :map => [])
    double("AWS::S3", buckets: hash_dbl)
  end

  subject :provider do
    described_class.new(
      DummyContext.new, :access_key_id => access_key_id, :secret_access_key => secret_access_key,
      :region => region, :app => app, :env => env, :bucket_name => bucket_name, :bucket_path => bucket_path,
      :only_create_app_version => only_create_app_version,
      :wait_until_deployed => wait_until_deployed
    )
  end

  subject :provider_without_bucket_path do
    described_class.new(
      DummyContext.new, :access_key_id => access_key_id, :secret_access_key => secret_access_key,
      :region => region, :app => app, :env => env, :bucket_name => bucket_name
    )
  end

  describe "#check_auth" do
    example do
      expect(AWS).to receive(:config).with(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
      provider.check_auth
    end
  end

  describe "#push_app" do

    let(:bucket_name) { "travis-elasticbeanstalk-test-builds-#{region}" }
    let(:app_version) { Object.new }

    example 'bucket exists already' do
      allow(s3_mock.buckets).to receive(:map).and_return([bucket_name])

      expect(provider).to receive(:s3).and_return(s3_mock).twice
      expect(provider).not_to receive(:create_bucket)
      expect(provider).to receive(:create_zip).and_return('/path/to/file.zip')
      expect(provider).to receive(:archive_name).and_return('file.zip')
      expect(bucket_mock.objects).to receive(:[]).with("#{bucket_path}/file.zip").and_return(bucket_mock)
      expect(provider).to receive(:upload).with('file.zip', '/path/to/file.zip').and_call_original
      expect(provider).to receive(:sleep).with(5)
      expect(provider).to receive(:create_app_version).with(bucket_mock).and_return(app_version)
      expect(provider).to receive(:update_app).with(app_version)

      provider.push_app
    end

    example 'bucket doesnt exist yet' do
      expect(provider).to receive(:s3).and_return(s3_mock).twice
      expect(provider).to receive(:create_bucket)
      expect(provider).to receive(:create_zip).and_return('/path/to/file.zip')
      expect(provider).to receive(:archive_name).and_return('file.zip')
      expect(provider).to receive(:upload).with('file.zip', '/path/to/file.zip').and_call_original
      expect(provider).to receive(:sleep).with(5)
      expect(provider).to receive(:create_app_version).with(bucket_mock).and_return(app_version)
      expect(provider).to receive(:update_app).with(app_version)

      provider.push_app
    end

    context 'only creates app version' do
      let(:only_create_app_version) { true }

      example 'verify the app is not updated' do

        expect(provider).to receive(:s3).and_return(s3_mock).twice
        expect(provider).to receive(:create_bucket)
        expect(provider).to receive(:create_zip).and_return('/path/to/file.zip')
        expect(provider).to receive(:archive_name).and_return('file.zip')
        expect(provider).to receive(:upload).with('file.zip', '/path/to/file.zip').and_call_original
        expect(provider).to receive(:sleep).with(5)
        expect(provider).to receive(:create_app_version).with(bucket_mock).and_return(app_version)
        expect(provider).not_to receive(:update_app).with(app_version)

        provider.push_app
      end
    end

    context 'When the bucket_path option is not set' do
      example 'Does not prepend bucket_path to the s3 bucket' do
        allow(s3_mock.buckets).to receive(:map).and_return([bucket_name])

        expect(provider_without_bucket_path).to receive(:s3).and_return(s3_mock).twice
        expect(provider_without_bucket_path).not_to receive(:create_bucket)
        expect(provider_without_bucket_path).to receive(:create_zip).and_return('/path/to/file.zip')
        expect(provider_without_bucket_path).to receive(:archive_name).and_return('file.zip')
        expect(provider_without_bucket_path).to receive(:bucket_path).and_return(nil)
        expect(bucket_mock.objects).to receive(:[]).with("file.zip").and_return(bucket_mock)
        expect(provider_without_bucket_path).to receive(:upload).with('file.zip', '/path/to/file.zip').and_call_original
        expect(provider_without_bucket_path).to receive(:sleep).with(5)
        expect(provider_without_bucket_path).to receive(:create_app_version).with(bucket_mock).and_return(app_version)
        expect(provider_without_bucket_path).to receive(:update_app).with(app_version)

        provider_without_bucket_path.push_app
      end
    end

    context 'When wait_until_deployed option is set' do
      let(:wait_until_deployed) { true }

      example 'Waits until deployment completes' do
        expect(provider).to receive(:s3).and_return(s3_mock).twice
        expect(provider).to receive(:create_bucket)
        expect(provider).to receive(:create_zip).and_return('/path/to/file.zip')
        expect(provider).to receive(:archive_name).and_return('file.zip')
        expect(provider).to receive(:upload).with('file.zip', '/path/to/file.zip').and_call_original
        expect(provider).to receive(:sleep).with(5)
        expect(provider).to receive(:create_app_version).with(bucket_mock).and_return(app_version)
        expect(provider).to receive(:update_app).with(app_version)
        expect(provider).to receive(:wait_until_deployed)

        provider.push_app
      end
    end
  end
end
