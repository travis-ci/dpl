require 'spec_helper'
require 'dpl/provider/transifex'

describe DPL::Provider::Transifex do
  let(:options) do
    {
      hostname: 'https://www.nottransifex.example.com',
      username: 'travis',
      password: 'secret',
      token: 'abcd1234'
    }
  end

  subject :provider do
    described_class.new(DummyContext.new, options)
  end

  describe '#install_deploy_dependencies' do
    context 'without version specified' do
      example "installs #{described_class::DEFAULT_CLIENT_VERSION}" do
        expect(provider.class).to(
          receive(:pip).with('transifex', 'transifex', described_class::DEFAULT_CLIENT_VERSION)
        )
        provider.install_deploy_dependencies
      end
    end

    context 'with version specified' do
      before do
        options[:cli_version] = '==0.12'
      end

      example 'installs custom version' do
        expect(provider.class).to(
          receive(:pip).with('transifex', 'transifex', '==0.12')
        )
        provider.install_deploy_dependencies
      end
    end
  end

  describe '#needs_key?' do
    example do
      expect(provider.needs_key?).to eq(false)
    end
  end

  describe '#check_auth' do
    before do
      allow(provider).to receive(:install_deploy_dependencies)
      allow(provider).to receive(:write_transifexrc)
    end

    example 'installs dependencies' do
      expect(provider).to receive(:install_deploy_dependencies)
      provider.check_auth
    end

    example 'writes ~/.transifexrc' do
      expect(provider).to receive(:write_transifexrc)
      provider.check_auth
    end

    example 'performs a tx status' do
      expect(provider.context).to receive(:shell).with('tx status')
      provider.check_auth
    end
  end

  describe '#push_app' do
    example 'delegates to the #source_push method' do
      expect(provider).to receive(:source_push)
      provider.push_app
    end
  end

  describe '#source_push' do
    example 'performs a tx push' do
      expect(provider.context).to(
        receive(:shell).with('tx push --source --no-interactive', retry: true)
      )
      provider.source_push
    end
  end

  describe '#write_transifexrc' do
    let(:fake_config) { StringIO.new }

    before do
      allow(File).to receive(:open).and_yield(fake_config)
    end

    example 'writes config with hostname header' do
      expect(fake_config).to receive(:puts).with(/^\[#{options[:hostname]}\]/)
      provider.write_transifexrc
    end

    %w(
      hostname
      username
      password
      token
    ).map(&:to_sym).each do |key|
      example "writes config with #{key} key" do
        expect(fake_config).to receive(:puts).with(/^#{key} = #{options[key]}$/)
        provider.write_transifexrc
      end
    end
  end
end
