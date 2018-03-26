require 'spec_helper'
require 'dpl/provider/now'

describe DPL::Provider::Now do
  subject :provider do
    described_class.new(DummyContext.new, :deploy_name => 'my-deploy-name')
  end
 
  describe '#check_auth' do
    it 'should require a token if no NOW_TOKEN is set' do
      expect{ provider.check_auth }.to raise_error('> Error!! Please add NOW_TOKEN Environment Variables in Travis settings (get your token here https://zeit.co/account/tokens)')
    end

    it 'should allow no token if NOW_TOKEN is set' do
      provider.context.env['NOW_TOKEN'] = '000000000000000000000000'
      expect{ provider.check_auth }.not_to raise_error
    end
  end

  describe '#push_app' do
    it 'should return auth token' do
      provider.context.env['NOW_TOKEN'] = '000000000000000000000000'
      expect(provider.auth).to include('--token 000000000000000000000000')
    end

    it 'should return deploy options' do
      expect(provider.deploy_options).to eq('--no-clipboard --name my-deploy-name')
    end

    it 'should return alias' do
      provider.context.env['NOW_TOKEN'] = '000000000000000000000000'
      provider.options.update(alias: 'alias.now.sh')
      expect(provider.context).to receive(:shell).with('now alias --token 000000000000000000000000  https://deployment_url.now.sh alias.now.sh').and_return('https://alias.now.sh')
      provider.aliasing('https://deployment_url.now.sh')
    end
  end
end
