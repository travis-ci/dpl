require 'spec_helper'
require 'dpl/provider/ninefold'

describe DPL::Provider::Ninefold do
  subject :provider do
    described_class.new(DummyContext.new, :auth_token => "123456789", :app_id => "1234")
  end

  describe "#check_auth" do
    it 'requires an auth token' do
      provider.options.update(:auth_token => nil)
      expect{ provider.check_auth }.to raise_error "must supply an auth token"
    end
  end

  describe "#check_app" do
    it 'requires an app ID' do
      provider.options.update(:app_id => nil)
      expect{ provider.check_app }.to raise_error "must supply an app ID"
    end
  end

  describe "#needs_key?" do
    it 'returns false' do
      expect(provider.needs_key?).to be_falsey
    end
  end

  describe "#push_app" do
    it 'includes the auth token and app ID specified' do
      expect(provider.context).to receive(:shell).with("AUTH_TOKEN=123456789 APP_ID=1234 ninefold app redeploy --sure")
      provider.push_app
    end
  end
end
