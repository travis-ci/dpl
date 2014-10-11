require 'spec_helper'
require 'aws-sdk'
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
  let(:bucket_name) { "travis-elasticbeanstalk-builds-#{region}" }

  subject :provider do
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

    let(:bucket_name) { "travis-elasticbeanstalk-builds-#{region}" }
    let(:s3_object) { Object.new }
    let(:app_version) { Object.new }

    let(:bucket) { Struct.new(:name) }
    let(:s3) { Struct.new(:buckets) }

    example 'bucket exists already' do
      s3_mock = s3.new([bucket.new(bucket_name)])
      expect(provider).to receive(:s3).and_return(s3_mock)
      expect(provider).not_to receive(:create_bucket)
      expect(provider).to receive(:create_zip).and_return('/path/to/file.zip')
      expect(provider).to receive(:archive_name).and_return('file.zip')
      expect(provider).to receive(:upload).with('file.zip', '/path/to/file.zip').and_return(s3_object)
      expect(provider).to receive(:sleep).with(5)
      expect(provider).to receive(:create_app_version).with(s3_object).and_return(app_version)
      expect(provider).to receive(:update_app).with(app_version)

      provider.push_app
    end

    example 'bucket doesnt exist yet' do
      s3_mock = s3.new([])
      expect(provider).to receive(:s3).and_return(s3_mock)
      expect(provider).to receive(:create_bucket)
      expect(provider).to receive(:create_zip).and_return('/path/to/file.zip')
      expect(provider).to receive(:archive_name).and_return('file.zip')
      expect(provider).to receive(:upload).with('file.zip', '/path/to/file.zip').and_return(s3_object)
      expect(provider).to receive(:sleep).with(5)
      expect(provider).to receive(:create_app_version).with(s3_object).and_return(app_version)
      expect(provider).to receive(:update_app).with(app_version)

      provider.push_app
    end
  end
end
