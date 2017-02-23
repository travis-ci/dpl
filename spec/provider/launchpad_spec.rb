require 'spec_helper'
require 'dpl/provider/launchpad'

describe DPL::Provider::Launchpad do
  subject :provider do
    described_class.new(DummyContext.new, :slug => '~user/repo/branch', :oauth_token => 'uezinoosinmxkewhochq', :oauth_token_secret => 'dinb6fao4jh0kfdn5mich31cbikdkpjplkmadhi80h93kbbaableeeg41mm0jab9jif8ch7i2k9a80n5')
  end

  its(:needs_key?) { should be false }

  describe '#push_app' do
    it 'on api success' do
      expect(provider).to receive(:api_call).with('/1.0/~user/repo/branch/+code-import', {'ws.op' => 'requestImport'}).and_return Net::HTTPSuccess.new("HTTP/1.1", 200, "Ok")
      provider.push_app
    end

    it 'on api failure' do
      expect(provider).to receive(:api_call).with('/1.0/~user/repo/branch/+code-import', {'ws.op' => 'requestImport'}).and_return double("Net::HTTPUnauthorized", code: 401, body: "", class: Net::HTTPUnauthorized)
      expect { provider.push_app }.to raise_error(DPL::Error)
    end
  end

  describe 'private method' do
    describe '#authorization' do
      it 'should return correct oauth' do
        result = provider.instance_eval { authorization }
        expect(result).to include('oauth_token="uezinoosinmxkewhochq",')
        expect(result).to include('oauth_signature="%26dinb6fao4jh0kfdn5mich31cbikdkpjplkmadhi80h93kbbaableeeg41mm0jab9jif8ch7i2k9a80n5",')
      end
    end
  end

end
