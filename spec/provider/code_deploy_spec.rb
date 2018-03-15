require 'spec_helper'
require 'aws-sdk'
require 'dpl/error'
require 'dpl/provider'
require 'dpl/provider/code_deploy'

describe DPL::Provider::CodeDeploy do

  subject :provider do
    described_class.new(DummyContext.new, :access_key_id => 'qwertyuiopasdfghjklz', :secret_access_key => 'qwertyuiopasdfghjklzqwertyuiopasdfghjklz')
  end

  describe '#code_deploy_options' do
    context 'without region' do
      example do
        options = provider.code_deploy_options
        expect(options[:region]).to eq('us-east-1')
      end
    end

    context 'with region' do
      example do
        region = 'us-west-1'
        provider.options.update(:region => region)
        options = provider.code_deploy_options
        expect(options[:region]).to eq(region)
      end
    end

    context 'without endpoint' do
      example do
        options = provider.code_deploy_options
        expect(options[:endpoint]).to eq(nil)
      end
    end

    context 'with endpoint' do
      example do
        endpoint = 's3test.com.s3-website-us-west-2.amazonaws.com'
        provider.options.update(:endpoint => endpoint)
        options = provider.code_deploy_options
        expect(options[:endpoint]).to eq(endpoint)
      end
    end
  end
end

describe DPL::Provider::CodeDeploy do
  access_key_id = 'someaccesskey'
  secret_access_key = 'somesecretaccesskey'
  application = 'app'
  deployment_group = 'group'
  description = 'description'
  revision = '23jkljkl'
  client_options = {
    :stub_responses => true,
    :region => 'us-east-1',
    :credentials => ::Aws::Credentials.new(access_key_id, secret_access_key),
    :endpoint => 'https://codedeploy.us-east-1.amazonaws.com'
  }

  subject :provider do
    described_class.new(DummyContext.new, {
      :access_key_id => access_key_id,
      :secret_access_key => secret_access_key
    })
  end

  before :each do
    provider.stub(:code_deploy_options).and_return(client_options)
  end

  describe '#code_deploy' do
    example do
      expect(::Aws::CodeDeploy::Client).to receive(:new).with(client_options).once
      provider.code_deploy
    end
  end

  describe '#needs_key?' do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe '#revision' do
    expected_s3_revision = {
      revision_type: 'S3',
      s3_location: {
        bucket:      'bucket',
        bundle_type: 'tar',
        key:         'key',
        version:     'object_version_id',
        e_tag:       'etag'
      }
    }

    expected_github_revision = {
      revision_type: 'GitHub',
      git_hub_location: {
        commit_id:  '2lk3j4k2j3k4j23k4j',
        repository: 'travis-ci/dpl'
      }
    }

    before(:each) do
      provider.stub(:s3_revision).and_return(expected_s3_revision)
      provider.stub(:github_revision).and_return(expected_github_revision)
    end

    context 'when s3' do
      before do
        provider.options.update(:revision_type => :s3)
      end

      example do
        expect(provider.revision).to eq(expected_s3_revision)
      end
    end

    context 'when github' do
      before do
        provider.options.update(:revision_type => :github)
      end

      example do
        expect(provider.revision).to eq(expected_github_revision)
      end
    end

    context 'when not specified' do
      before do
        provider.options.update(:bucket => 'bucket')
      end

      example do
        expect(provider.revision).to eq(expected_s3_revision)
      end
    end

    context 'when revision and bucket are not specified' do
      example do
        expect(provider.revision).to eq(expected_github_revision)
      end
    end

    context 'when not a known revision type' do
      type = :bad

      before do
        provider.options.update(:revision_type => type)
      end

      example do
        expect(provider).to receive(:error).with(/unknown revision type :#{type}/)
        provider.revision
      end
    end
  end

  describe '#s3_revision' do
    bucket = 'bucket'
    bundle_type = 'tar'
    key = "/some/key.#{bundle_type}"

    before(:each) do
      head_data = provider.s3api.stub(:head_object).and_return({
        version_id: 'object_version_id',
        etag: 'etag'
      })
      provider.s3api.stub_responses(:head_object, head_data)
      expect(provider).to receive(:option).at_least(1).times.with(:bucket).and_return(bucket)
      expect(provider).to receive(:bundle_type).and_return(bundle_type)
      expect(provider).to receive(:s3_key).at_least(1).times.and_return(key)
    end

    example do
      expect(provider.s3_revision[:s3_location]).to include(
          bucket: bucket,
          bundle_type: bundle_type,
          key: key,
          version: 'object_version_id',
          e_tag: 'etag'
        )
    end
  end

  describe '#github_revision' do
    commit_id = '432s35s3'
    repository = 'git@github.com/org/repo.git'

    context 'with options set' do
      before(:each) do
        expect(provider.options).to receive(:[]).with(:commit_id).and_return(commit_id)
        expect(provider.options).to receive(:[]).with(:repository).and_return(repository)
      end

      example do
        expect(provider.github_revision).to eq({
          revision_type: 'GitHub',
          git_hub_location: {
            commit_id: commit_id,
            repository: repository
          }
        })
      end
    end

    context 'with environment variables' do
      before(:each) do
        expect(provider.options).to receive(:[]).with(:commit_id).and_return(nil)
        expect(provider.options).to receive(:[]).with(:repository).and_return(nil)
        expect(provider.context.env).to receive(:[]).with('TRAVIS_COMMIT').and_return(commit_id)
        expect(provider.context.env).to receive(:[]).with('TRAVIS_REPO_SLUG').and_return(repository)
      end

      example do
        expect(provider.github_revision).to eq({
          revision_type: 'GitHub',
          git_hub_location: {
            commit_id: commit_id,
            repository: repository
          }
        })
      end
    end

    context 'without required options' do
      before(:each) do
        expect(provider.options).to receive(:[]).with(:commit_id).and_return(nil)
        provider.options.stub(:[]).with(:repository) { nil }
        expect(provider.context.env).to receive(:[]).with('TRAVIS_COMMIT').and_return(nil)
        expect(provider.context.env).to receive(:[]).with('TRAVIS_REPO_SLUG').and_return(nil)
      end

      example do
        expect{provider.github_revision}.to raise_error(DPL::Error)
      end
    end
  end

  describe '#push_app' do
    before(:each) do
      old_options = provider.options
      provider.stub(:options) {old_options.merge({
        :application_name => application,
        :deployment_group_name => deployment_group,
        :description => description,
        :repository => 'git@github.com:travis-ci/dpl.git'
      })}
    end

    context 'without an error' do
      deployment_id = 'some-deployment-id'

      before do
        provider.code_deploy.stub_responses(:create_deployment, :deployment_id => deployment_id)
      end

      example do
        expect(provider).to receive(:log).with(/Triggered deployment \"#{deployment_id}\"\./)
        provider.push_app
      end

       before do
        allow(provider.code_deploy).to receive(:get_deployment).and_return(
          {:deployment_info => {:status => "Created"}},
          {:deployment_info => {:status => "Queued"}},
          {:deployment_info => {:status => "InProgress"}},
          {:deployment_info => {:status => "Succeeded"}})
      end

      example 'with :wait_until_deployed' do
        old_options = provider.options
        provider.stub(:options) {old_options.merge({
          app_id: 'app-id',
          wait_until_deployed: true})}
        expect(provider).to receive(:log).with(/Triggered deployment \"#{deployment_id}\"\./)
        expect(provider).to receive(:log).with(/Deployment successful./)
        provider.push_app
      end
    end

    context 'with an error' do
      before do
        provider.code_deploy.stub_responses(:create_deployment, 'DeploymentLimitExceededException')
      end

      example do
        expect(provider).to receive(:error).once
        provider.push_app
      end
    end
  end

  describe '#bundle_type' do
    context 'with s3_key' do
      format = 'zip'
      s3_key = "/some/key/name.#{format}"

      before(:each) do
        expect(provider).to receive(:s3_key).and_return(s3_key)
      end

      example do
        expect(provider.bundle_type).to eq(format)
      end
    end

    context 'without s3_key' do
      bundle_type = 'tar'

      before do
        expect(provider).to receive(:s3_key).and_return('')
        expect(provider).to receive(:option).with(:bundle_type).and_return(bundle_type)
      end

      example do
        expect(provider.bundle_type).to eq(bundle_type)
      end
    end
  end

  describe '#s3_key' do
    key = '/some/key/name.zip'

    context 'with key option' do
      before do
        expect(provider.options).to receive(:[]).with(:key).and_return(key)
      end

      example do
        expect(provider.s3_key).to eq(key)
      end
    end

    context 'with s3_key option' do
      before do
        expect(provider).to receive(:option).with(:s3_key).and_return(key)
      end

      example do
        expect(provider.s3_key).to eq(key)
      end
    end
  end

  describe '#default_description' do
    build_number = 2

    before do
      provider.context.env.stub(:[]).with('TRAVIS_BUILD_NUMBER').and_return(build_number)
    end

    example do
      expect(provider.default_description).to eq("Deploy build #{build_number} via Travis CI")
    end
  end

  describe '#check_auth' do
    example do
      expect(provider).to receive(:log).with("Logging in with Access Key: #{access_key_id[-4..-1].rjust(20, '*')}")
      provider.check_auth
    end
  end
end
