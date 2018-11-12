require 'base64'
require 'spec_helper'
require 'dpl/provider/ecr'

describe DPL::Provider::Ecr do
  let :options do
    {
      source: 'source/repo',
      target: 'target/repo'
    }
  end

  let :ecr_authorization do
    double(:ecr_authorization, authorization_data: [
      double(:registry_auth,
        authorization_token: Base64.encode64('ze-username:ze-token'),
        expires_at: Time.at(1234567890),
        proxy_endpoint: 'https://ze-endpoint',
      )
    ])
  end

  let :ecr_client do
    double(:ecr_client).tap do |c|
      allow(c).to receive(:get_authorization_token).and_return(ecr_authorization)
    end
  end

  let(:image) do
    double(:image).tap do |i|
      allow(i).to receive(:push)
    end
  end

  before do
    allow(Docker).to receive(:authenticate!).and_return(true)
    allow(Docker::Image).to receive(:get).and_return(image)
    allow(Aws::ECR::Client).to receive(:new).and_return(ecr_client)
  end

  subject :provider do
    described_class.new(DummyContext.new, **options)
  end

  around do |example|
    @old_env = ENV.to_h.dup
    example.run
    ENV.clear.update(@old_env)
  end

  describe '#validate' do
    let :options do
      super().merge(
        aws_region: 'rp-north-1',
        aws_account_id: '54321',
        aws_access_key_id: 'ANOTHERACCESSKEY',
        aws_secret_access_key: 'evenmoresecret',
      )
    end

    context 'with no source option' do
      let(:options) { super().reject{|k, _| k == :source } }

      it 'raises an error' do
        expect { provider.validate }.to raise_error(/source.*missing/im)
      end
    end

    context 'with no target option' do
      let(:options) { super().reject{|k, _| k == :target } }

      it 'raises an error' do
        expect { provider.validate }.to raise_error(/target.*missing/im)
      end
    end

    context 'with no region option' do
      let(:options) { super().reject{|k, _| k == :aws_region } }

      it 'raises an error' do
        expect { provider.validate }.to raise_error(/aws_region.*missing/im)
      end

      context 'and environment variable AWS_REGION' do
        before { ENV['AWS_REGION'] = 'rp-east-1' }

        it 'does not raise an error' do
          provider.validate
        end
      end
    end

    context 'with no access key option' do
      let(:options) { super().reject{|k, _| k == :aws_access_key_id } }

      it 'raises an error' do
        expect { provider.validate }.to raise_error(/aws_access_key_id.*missing/im)
      end

      context 'and environment variable AWS_ACCESS_KEY_ID' do
        before { ENV['AWS_ACCESS_KEY_ID'] = 'SOMEACCESSKEY' }

        it 'does not raise an error' do
          provider.validate
        end
      end
    end
  end

  describe '#check_auth' do
    before do
      ENV['AWS_ACCESS_KEY_ID'] = 'SOMEACCESSKEY'
      ENV['AWS_SECRET_ACCESS_KEY'] = 'verysecret'
      ENV['AWS_DEFAULT_REGION'] = 'rp-north-1'
    end

    context 'with minimal options' do
      it 'infers the rest from environment variables' do
        provider.check_auth
        expect(ecr_client).to have_received(:get_authorization_token).with({})
      end

      it 'uses the credentials to authenticate with the ECR registry' do
        provider.check_auth
        expect(Docker).to have_received(:authenticate!)
          .with(
            username: 'ze-username',
            password: 'ze-token',
            serveraddress: 'https://ze-endpoint'
          )
      end

      it 'remembers the endpoint' do
        provider.check_auth
        expect(provider.endpoints).to include('rp-north-1' => 'https://ze-endpoint')
      end
    end

    context 'with AWS_ACCOUNT_ID environment variable' do
      before do
        ENV['AWS_ACCOUNT_ID'] = '12345'
      end

      it 'passes that account id as registry id' do
        provider.check_auth
        expect(ecr_client).to have_received(:get_authorization_token).with(registry_ids: ['12345'])
      end
    end

    context 'with AWS_REGION environment variable' do
      before do
        ENV['AWS_REGION'] = 'rp-west-1'
      end

      it 'prefers AWS_REGION to AWS_DEFAULT_REGION' do
        provider.check_auth
        expect(Aws::ECR::Client).to have_received(:new).with(hash_including(region: 'rp-west-1'))
      end
    end

    context 'with explicitly configured aws credentials' do
      let :options do
        super().merge(
          aws_account_id: '54321',
          aws_access_key_id: 'ANOTHERACCESSKEY',
          aws_secret_access_key: 'evenmoresecret',
        )
      end

      it 'overrides credentials from environment variables' do
        provider.check_auth
        expect(Aws::ECR::Client).to have_received(:new).with(
          region: 'rp-north-1',
          aws_access_key_id: 'ANOTHERACCESSKEY',
          aws_secret_access_key: 'evenmoresecret',
        )
      end

      it 'uses the configured account id when reguesting authorization' do
        provider.check_auth
        expect(ecr_client).to have_received(:get_authorization_token).with(registry_ids: ['54321'])
      end
    end

    context 'with multiple regions' do
      let :options do
        super().merge(aws_region: ['rp-central-1', 'rp-south-1'])
      end

      it 'authenticates in both regions', :aggregate_failures do
        provider.check_auth
        expect(Aws::ECR::Client).to have_received(:new).with(region: 'rp-central-1')
        expect(Aws::ECR::Client).to have_received(:new).with(region: 'rp-south-1')
        expect(ecr_client).to have_received(:get_authorization_token).twice
      end

      it 'decorates each target with the corresponding endpoint', :aggregate_failures do
        provider.check_auth
        expect(provider.endpoints).to include('rp-central-1' => 'https://ze-endpoint')
        expect(provider.endpoints).to include('rp-south-1' => 'https://ze-endpoint')
      end
    end
  end

  describe '#check_app' do
    it 'validates that the image exists' do
      provider.check_app
      expect(Docker::Image).to have_received(:get).with('source/repo')
    end

    context 'when the image does not exist in the local repository' do
      before { allow(Docker::Image).to receive(:get).and_raise(Docker::Error::NotFoundError) }

      it 'raises a DPL error' do
        expect { provider.check_app }.to raise_error(DPL::Error, /source\/repo/)
      end
    end
  end

  describe '#push_app' do
    before do
      allow(provider).to receive(:endpoints).and_return({
        'rp-north-1' => 'https://north-endpoint',
        'rp-central-1' => 'https://central-endpoint',
        'rp-south-1' => 'https://south-endpoint'
      })
      ENV['AWS_REGION'] = 'rp-north-1'
    end

    context 'with minimal options' do
      it 'pushes the image to ecr' do
        provider.push_app
        expect(image).to have_received(:push).with(nil, repo_tag: 'north-endpoint/target/repo')
      end
    end

    context 'with multiple regions' do
      let :options do
        super().merge(aws_region: ['rp-central-1', 'rp-south-1'])
      end

      it 'pushes the image to both registries', :aggregate_failures do
        provider.push_app
        expect(image).to have_received(:push).with(nil, repo_tag: 'central-endpoint/target/repo')
        expect(image).to have_received(:push).with(nil, repo_tag: 'south-endpoint/target/repo')
      end
    end

    context 'with multiple targets' do
      let :options do
        super().merge(target: ['target/repo:1.0', 'target/repo:latest'])
      end

      it 'pushes the image with both tags', :aggregate_failures do
        provider.push_app
        expect(image).to have_received(:push).with(nil, repo_tag: 'north-endpoint/target/repo:1.0')
        expect(image).to have_received(:push).with(nil, repo_tag: 'north-endpoint/target/repo:latest')
      end
    end
  end
end
