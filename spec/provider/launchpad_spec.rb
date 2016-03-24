require 'spec_helper'
require 'dpl/provider/cloudcontrol'

describe DPL::Provider::Launchpad do
  subject :provider do
    described_class.new(DummyContext.new, :slug => '~user/repo/branch', :oauth_token => 'uezinoosinmxkewhochq', :oauth_token_secret => 'dinb6fao4jh0kfdn5mich31cbikdkpjplkmadhi80h93kbbaableeeg41mm0jab9jif8ch7i2k9a80n5')
  end

  its(:needs_key?) { should be false }

  describe '#push_app' do
    it 'on api success' do
      expect(provider).to receive(:api_call).with('/1.0/~user/repo/branch/+code-import', {'ws.op' => 'requestImport'}).and_return double(:code => '200')
      provider.push_app
    end

    it 'on api failure' do
      expect(provider).to receive(:api_call).with('/1.0/~user/repo/branch/+code-import', {'ws.op' => 'requestImport'}).and_return double(:code => '401')
      expect { provider.push_app }.to raise_error(DPL::Error)
    end
  end

  describe 'private method' do
    describe '#get_authorization_header' do
      it 'should return correct oauth header' do
        result = provider.instance_eval { get_authorization_header }
        expect(result).to include('oauth_token="uezinoosinmxkewhochq",')
        expect(result).to include('oauth_signature="%26dinb6fao4jh0kfdn5mich31cbikdkpjplkmadhi80h93kbbaableeeg41mm0jab9jif8ch7i2k9a80n5",')
      end
    end
  end

end
